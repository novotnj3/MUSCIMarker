from pythonforandroid.recipe import CythonRecipe
from pythonforandroid.logger import shprint, sh, info, info_main
from os.path import join


class LocalCythonRecipe(CythonRecipe):
    """Recipe mixin class that will automatically unpack files included in
    the local recipe directory."""

    src_filename = None

    def prepare_build_dir(self, arch):
        if self.src_filename is None:
            print('LocalCythonRecipe failed: no src_filename specified')
            exit(1)

        info_main('Unpacking {} for {}'.format(self.name, arch))

        # Remove existing files
        shprint(sh.rm, '-rf', self.get_build_dir(arch))

        recipes_dir = self.recipe_dirs(self.ctx)
        if not recipes_dir:
            print('No Recipe directories found!')
            exit(1)

        # Get the first recipe directory (should be the local one)
        source_dir = join(recipes_dir[0], self.name, self.src_filename)
        out_dir = self.get_build_dir(arch)
        shprint(sh.cp, '-a', source_dir, out_dir)
        info('Source files copied from {} to {}'.format(source_dir, out_dir))


class CImUtilsRecipe(LocalCythonRecipe):
    name = 'cimutils'
    version = '1.0'
    url = None

    src_filename = 'src'

    depends = ['python2', 'numpy']

recipe = CImUtilsRecipe()
