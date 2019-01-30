# This file is NOT licensed under the GPLv3, which is the license for the rest
# of YouCompleteMe.
#
# Here's the license text for this file:
#
# This is free and unencumbered software released into the public domain.
#
# Anyone is free to copy, modify, publish, use, compile, sell, or
# distribute this software, either in source code form or as a compiled
# binary, for any purpose, commercial or non-commercial, and by any
# means.
#
# In jurisdictions that recognize copyright laws, the author or authors
# of this software dedicate any and all copyright interest in the
# software to the public domain. We make this dedication for the benefit
# of the public at large and to the detriment of our heirs and
# successors. We intend this dedication to be an overt act of
# relinquishment in perpetuity of all present and future rights to this
# software under copyright law.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#
# For more information, please refer to <http://unlicense.org/>

from distutils.sysconfig import get_python_inc
import platform
import os
import re
import sys
import ycm_core
import json

cflags = [
'-std=c11',
]

cxxflags = [
'-std=gnu++14',
]

flags = [
'-Wall',
'-Wextra',
'-Wno-long-long',
'-Wno-variadic-macros',
'-fexceptions',
'-I',
'.',
]


def DirectoryOfThisScript():
  return os.path.dirname( os.path.abspath( __file__ ) )

# Replace with DirectoryOfThisScript() if copying to working directory
working_directory = os.getcwd()

compilation_database_folder = working_directory

if os.path.exists( compilation_database_folder ):
  database = ycm_core.CompilationDatabase( compilation_database_folder )
  try:
    with open(os.path.join(compilation_database_folder, 'compile_commands.json')) as db:
      database_json = json.load(db)
  except:
    database_json = []
else:
  database = None

SOURCE_EXTENSIONS = [ '.cpp', '.cxx', '.cc', '.c', '.m', '.mm' ]

def IsHeaderFile( filename ):
  extension = os.path.splitext( filename )[ 1 ]
  return extension in [ '.h', '.hxx', '.hpp', '.hh' ]

# Replace instances of source folders with includes to try to find a
# corresponding source file.
# E.g. a/b/include/c/x.hpp -> a/b/src/c/x.cpp
def FindHeaderCompileFlagsByPath( cdb, filename ):
  print('FindHeaderCompileFlagsByPath')
  path_comp = []
  path_rem = filename

  while not path_rem in [ '', '/' ]:
    path_rem, comp = os.path.split(path_rem)
    path_comp.append(comp)

  paths = [path_comp]

  for idx, comp in enumerate(path_comp):
    if comp in [ 'include', 'inc', 'Include' ]:
      for src_dir in [ 'src', 'source', 'Source' ]:
        cpy = path_comp.copy()
        cpy[idx] = src_dir
        paths.append(cpy)

  for path in paths:
    path.append('/') # make it absolute
    path.reverse()
    path_str = os.path.splitext(os.path.join(*tuple(path)))[0]

    for ext in SOURCE_EXTENSIONS:
      src_file = path_str + ext
      print('Try Path: ', src_file)
      compilation_info = cdb.GetCompilationInfoForFile( src_file )
      if compilation_info.compiler_flags_:
        print('Found Compile Info: ', src_file)
        return (compilation_info, src_file)

  return (None, None)

# Find a file that has the same name (minus the extension)
# E.g. abcd.hpp and abcd.cpp
# if multiple are found we use the one which is closest to the file
def FindHeaderCompileFlagsByFilename(cdb, filename):
  print('FindHeaderCompileFlagsByFilename')
  fname = os.path.splitext(os.path.basename(filename))[0]
  same_name_files = []

  for entry in database_json:
    if fname == os.path.splitext(os.path.basename(entry['file']))[0]:
      same_name_files.append(os.path.join(entry['directory'], entry['file']))

  print("Same name files: ", same_name_files)

  if len(same_name_files) == 0:
    return (None, None)

  compilation_info = None
  compilation_file = None
  longest_len = 0
  for f in same_name_files:
    c_info = cdb.GetCompilationInfoForFile(f)
    l = len(os.path.commonpath([f, filename]))
    if l >= longest_len and c_info.compiler_flags_:
      print('Longest = ', f)
      compilation_info = c_info
      compilation_file = f
      longest_len = l

  return (compilation_info, compilation_file)

def Settings( **kwargs ):
  if kwargs['language'] != 'cfamily':
    return {}

  filename = kwargs['filename']

  try:
    project_root = kwargs['client_data']['g:ycm_guoj_project_root']
  except KeyError:
    project_root = working_directory

  if not database:
    curflags = flags

    extension = os.path.splitext( filename )[ 1 ]
    if extension == '.c':
      curflags += cflags
    else:
      curflags += cxxflags

    return {
      'flags': flags,
      'include_paths_relative_to_dir': project_root,
      'override_filename': filename
    }

  compilation_info = database.GetCompilationInfoForFile( filename )
  compilation_file = None

  if not compilation_info.compiler_flags_:
    if IsHeaderFile(filename):
      # Try a similar path to find a source with the same name
      (compilation_info, compilation_file) = FindHeaderCompileFlagsByPath(database, filename)

      if not compilation_info or not compilation_info.compiler_flags_:
        # Try finding any file with the same name
        (compilation_info, compilation_file) = FindHeaderCompileFlagsByFilename(database, filename)

    # If we still cannot find flags, just use generic ones
    if not compilation_info or not compilation_info.compiler_flags_:
      return {
        'flags': flags,
        'include_paths_relative_to_dir': project_root,
        'override_filename': filename
      }
    #else:
    #  filename = compilation_file

  final_flags = list( compilation_info.compiler_flags_ )

  if compilation_file and os.path.splitext( compilation_file )[ 1 ] != '.c':
    final_flags.append('-xc++')

  return {
    'flags': final_flags,
    'include_paths_relative_to_dir': compilation_info.compiler_working_dir_,
    'override_filename': filename
  }
