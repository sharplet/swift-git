#include <git2.h>

__attribute__((constructor))
static void
swift_git_init(void)
{
  git_libgit2_init();
}
