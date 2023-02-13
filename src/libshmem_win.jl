#################################################################################
#  Shared mem & Semaphores functions
#################################################################################

import Base: OS_HANDLE, INVALID_OS_HANDLE, Process
using Random
using Avro

const PAGE_READONLY          = Culong(0x02)
const PAGE_READWRITE         = Culong(0x04)

const PROT_READ     = Cint(1)
const PROT_WRITE    = Cint(2)
const MAP_SHARED    = Cint(1)
const MAP_PRIVATE   = Cint(2)
const MAP_ANONYMOUS = Cint(Sys.isbsd() ? 0x1000 : 0x20)
const F_GETFL       = Cint(3)

const FILE_MAP_WRITE         = Culong(0x02)
const FILE_MAP_READ          = Culong(0x04)

const WAIT_OBJECT  = Culong(0x0)        # signaled
const WAIT_TIMEOUT = Culong(0x102)      # The time-out interval elapsed, and the object's state is nonsignaled.
const WAIT_FAILED  = Culong(0xFFFFFFFF) # The function has failed. To get extended error information, call GetLastError.


################# main funcs  ############################################################
# msg type for Avro coding / decoding
struct MsgType
    label::String
    detail::String
    text::String
    data::Vector{UInt8}
end

function postAndWait(msg::MsgType, timeout=10000)
    checkServer() # check if available, launch a new one if necessary

    buf = IOBuffer()
    sz = Avro.write(buf, msg)
    writeShmem(buf.data[1:sz]) # write to shared mem 

    # signal server that data is here
    ccall(:ReleaseSemaphore, stdcall, Cint, (Ptr{Cvoid}, Clong, Clong), comm.cSema, 1, 0) 
    
    # now wait for response from server
    if waitSem(timeout)
        buf = IOBuffer(readServerMem())
        return Avro.read(buf, MsgType)
    else
        return nothing
    end
end

################# internal funcs  ############################################################
# global var containing current server/connection stuff
comm = nothing

mutable struct Comm
    sProcess::Process   # server process
    name::String
    fd::Ptr{Cvoid}             # file descriptor for our (=client) shared mem
    cSema::Ptr{Cvoid}          # our semaphore (to signal we have sent a request)
    sSema::Ptr{Cvoid}          # server semaphore (for the server to signal a response is available)

    Comm() = commInit(new())
end

function commInit(comm::Comm)  # comm is unitialized object
    # cname = (name !== nothing) ? name : "/$(randstring(20))"
    comm.name = randstring(10)  # "abcd"
    comm.fd = C_NULL

    # launch server
    println("launching VegaLite server (prefix = $(comm.name))")
    exepath = "C:/Users/frtestar/OneDrive - GROUP DIGITAL WORKPLACE/Documents/devls/pkgtest/server.js"
    logpath = " c:/temp/slog.txt"
    scmd = `node $exepath $(comm.name)`
    comm.sProcess = run(scmd, nothing, logpath, logpath, wait=false)

    # create semaphores
    comm.cSema = ccall(:CreateSemaphoreA, stdcall, Ptr{Cvoid}, (Culong, Clong, Clong, Cwstring),
    0, 0, 1, "client-" * comm.name) 
    Base.windowserror(:CreateSemaphoreA, comm.cSema == C_NULL)

    comm.sSema = ccall(:CreateSemaphoreA, stdcall, Ptr{Cvoid}, (Culong, Clong, Clong, Cwstring),
    0, 0, 1, "server-" * comm.name) 
    Base.windowserror(:CreateSemaphoreA, comm.sSema == C_NULL)

    # now wait for server to signal it's ready (10 second timeout)
    ret = ccall(:WaitForSingleObject, stdcall, Clong, (Ptr{Cvoid}, Clong), comm.sSema, 10000) 
    if ret != WAIT_OBJECT
        kill(comm.sProcess) # in case it is running
        error("VL did not respond within delay")
    end

    finalizer(commCleanup, comm)
    comm
end

function commCleanup(c::Comm)
    @async println("finalizing VL server stuff")

    # close Semaphores
    if c.cSema != C_NULL
    end
    
    if c.cSema != C_NULL
    end
    
    # close shared mem
    if c.fd != C_NULL
        ccall(:CloseHandle, stdcall, Cint, (Ptr{Cvoid},), c.fd)
    end

    # kill server
    kill(c.sProcess)
end    

# checks if a server is running, (re-)launching if necessary
function checkServer()
    global comm

    if comm === nothing
        comm = Comm()
    elseif !process_running(comm.sProcess)
        comm = Comm()  # should also trigger finalizing of previous comm
    end
end 

# create a shared mem, optionnaly closing pre-existing one
function createShm(sz=0)
    if comm.fd != C_NULL
        status = ccall(:CloseHandle, stdcall, Cint, (Ptr{Cvoid},), comm.fd)!=0
        Base.windowserror(:CloseHandle, status == 0)
    end

    comm.fd = ccall(:CreateFileMappingW, stdcall, Ptr{Cvoid}, (OS_HANDLE, Ptr{Cvoid}, Culong, Culong, Culong, Cwstring),
        INVALID_OS_HANDLE, C_NULL, PAGE_READWRITE, 0, sz, comm.name * "-client") 
    Base.windowserror(:CreateFileMappingW, comm.fd == C_NULL)

    true
end

function openMem(f::Function)
    # open
    sfd = ccall(:OpenFileMappingW, stdcall, Ptr{Cvoid}, (Culong, Culong, Cwstring),
        FILE_MAP_READ, true, comm.name * "-server")
    Base.windowserror(:OpenFileMappingW, sfd == C_NULL)

    f(sfd)

    # close
    status = ccall(:CloseHandle, stdcall, Cint, (Ptr{Cvoid},), sfd)
    Base.windowserror(:CloseHandle, status == 0)
end

# returns an array wrapping the shared mem
function readServerMem()
    res = nothing
    openMem() do sfd
        # read out the size (4 bytes)
        hdl = ccall(:MapViewOfFile, stdcall, Ptr{Cvoid}, (Ptr{Cvoid}, Culong, Culong, Culong, Csize_t),
            sfd, FILE_MAP_READ, 0, 0, 4)
        Base.windowserror(:wrapShmem, hdl == C_NULL)
        sz = unsafe_load(convert(Ptr{UInt32}, UInt(hdl)))
        println("reading $sz bytes")
    
        # read out the data    
        hdl = ccall(:MapViewOfFile, stdcall, Ptr{Cvoid}, (Ptr{Cvoid}, Culong, Culong, Culong, Csize_t),
            sfd, FILE_MAP_READ, 0, 0, sz)
        Base.windowserror(:wrapShmem, hdl == C_NULL)
    
        # FIXME : good for utf16 strings only, not binary
        res = copy(unsafe_wrap(Array, convert(Ptr{UInt8}, UInt(hdl + 4)), sz))
    
        # unmap
        status = ccall(:UnmapViewOfFile, stdcall, Cint, (Ptr{Cvoid},), hdl)
        Base.windowserror(:UnmapViewOfFile, status == 0)
    end

    return res
end

# saves the data in the shared mem, returns the size
function writeShmem(dat::Vector{UInt8})
    # prepare data
    # intbuf = IOBuffer()
    # write(intbuf, dat)
    # _dat = take!(intbuf)

    sz = UInt32(length(dat))
    _dat = vcat(UInt8[ sz % 256, (sz >> 8) % 256,  (sz >> 16) % 256, sz >> 24 ], dat)

    # close existing and recreate mem to allow resize
    createShm(sz+4)

    hdl = ccall(:MapViewOfFile, stdcall, Ptr{Cvoid}, (Ptr{Cvoid}, Culong, Culong, Culong, Csize_t),
                    comm.fd, FILE_MAP_WRITE, 0, 0, sz+4)
    Base.windowserror(:MapViewOfFile, hdl == C_NULL)

    dest = unsafe_wrap(Array, convert(Ptr{UInt8}, UInt(hdl)), sz+4)
    copy!(dest, _dat)

    # unmap
    status = ccall(:UnmapViewOfFile, stdcall, Cint, (Ptr{Cvoid},), hdl)
    Base.windowserror(:UnmapViewOfFile, status == 0)
    
    return sz
end


############  semaphores

# create client and server semaphores


# wait for semaphore #2
function waitSem(timeout::Int)
    ret = ccall(:WaitForSingleObject, stdcall, Clong, (Ptr{Cvoid}, Clong), comm.sSema, timeout) 
    if ret == WAIT_OBJECT
        return true
    elseif ret == WAIT_TIMEOUT
        error("VL did not respond within delay")
    end

    false
end







