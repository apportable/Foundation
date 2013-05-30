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

static NSInteger _mach_port_create() 
{
	static pthread_mutex_t portLock = PTHREAD_MUTEX_INITIALIZER;
	pthread_mutex_lock(&portLock);
	_mach_port_ref++;
	mach_port_pipe_t *entry = (mach_port_pipe_t *)malloc(sizeof(mach_port_pipe_t));
	pipe(entry->pipe);
	write(entry->pipe[0], &wakeupByte, sizeof(unsigned char));
	HASH_ADD_INT(ports, port, entry);
	pthread_mutex_unlock(&portLock);
	return entry->port;
}

static mach_port_pipe_t *_mach_port_find(NSInteger port)
{
    mach_port_pipe_t *entry;
    HASH_FIND_INT(ports, &port, entry);
    return entry;
}

@implementation NSMachPort

- (id)initWithMachPort:(NSInteger)port
{
	self = [super init];
	if (self)
	{
		_port = _mach_port_find(port);
	}
	return self;
}

+ (NSPort *)port
{
	return [[NSMachPort alloc] initWithMachPort:_mach_port_create()];
}

+ (NSPort *)portWithMachPort:(NSInteger)machPort
{
	return [[[self alloc] initWithMachPort:machPort] autorelease];
}

- (void)receivedEvent:(void *)data type:(int)type extra:(void *)extra forMode:(NSString *)mode
{
	write(((mach_port_pipe_t *)_port)->pipe[0], &wakeupByte, sizeof(unsigned char));
}

- (BOOL)runLoopShouldBlock:(BOOL *)ctx
{
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
