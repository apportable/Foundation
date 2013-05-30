#import "Foundation/NSMachPort.h"
#import "Foundation/uthash.h"
#import <sys/socket.h>
#import <pthread.h>
#import <unistd.h>

typedef struct {
    NSInteger port;
    int pipe[2];
    UT_hash_handle hh;
} mach_port_pipe_t;

static NSInteger _mach_port_ref = 0;
static mach_port_pipe_t *ports = NULL;

unsigned char wakeupByte = 0x42;

static pthread_mutex_t portLock = PTHREAD_MUTEX_INITIALIZER;

static mach_port_pipe_t *_mach_port_create()
{
    pthread_mutex_lock(&portLock);
    _mach_port_ref++;
    mach_port_pipe_t *entry = (mach_port_pipe_t *)malloc(sizeof(mach_port_pipe_t));
    pipe(entry->pipe);
    write(entry->pipe[0], &wakeupByte, sizeof(unsigned char));
    HASH_ADD_INT(ports, port, entry);
    pthread_mutex_unlock(&portLock);
    return entry;
}

static mach_port_pipe_t *_mach_port_find(NSInteger port)
{
    mach_port_pipe_t *entry = NULL;
    pthread_mutex_lock(&portLock);
    HASH_FIND_INT(ports, &port, entry);
    pthread_mutex_unlock(&portLock);
    return entry;
}

static void _mach_port_destroy(mach_port_pipe_t *entry)
{
    if (entry != NULL)
    {
        pthread_mutex_lock(&portLock);
        close(entry->pipe[0]);
        close(entry->pipe[1]);
        HASH_DEL(ports, entry);
        free(entry);
        pthread_mutex_unlock(&portLock);
    }
}

@implementation NSMachPort

- (id)init
{
    self = [super init];
    if (self)
    {
        _port = _mach_port_create();
    }
    return self;
}

- (id)initWithMachPort:(NSInteger)port
{
    self = [super init];
    if (self)
    {
        _port = _mach_port_find(port);
    }
    return self;
}

- (void)dealloc
{
    _mach_port_destroy((mach_port_pipe_t *)_port);
    _port = NULL;
    [super dealloc];
}

+ (NSPort *)port
{
    return [[NSMachPort alloc] init];
}

+ (NSPort *)portWithMachPort:(NSInteger)machPort
{
    return [[[self alloc] initWithMachPort:machPort] autorelease];
}

- (void)receivedEvent:(void *)data type:(int)type extra:(void *)extra forMode:(NSString *)mode
{
    if (_port != NULL)
    {
        read(((mach_port_pipe_t *)_port)->pipe[1], &wakeupByte, sizeof(unsigned char));
        wakeupByte = 0x42;
        write(((mach_port_pipe_t *)_port)->pipe[0], &wakeupByte, sizeof(unsigned char));
    }
}

- (BOOL)runLoopShouldBlock:(BOOL *)ctx
{
    if (ctx != NULL)
    {
        *ctx = YES;
    }
    return NO;
}

- (void)getFds:(NSInteger *)fds count:(NSInteger *)count
{
    if (_port == NULL && count != NULL)
    {
        *count = 0;
    }
    else if (_port != NULL)
    {
        if (count != NULL)
        {
            *count = 1;
        }
        if (fds != NULL)
        {
            int portFd = ((mach_port_pipe_t *)_port)->pipe[1];
            memcpy(fds, &portFd, 1);
        }
    }
}

@end
