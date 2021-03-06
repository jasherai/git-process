# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'git-process/git_logger'
require 'git-process/git_branch'
require 'git-process/git_branches'
require 'git-process/git_status'
require 'git-process/git_process_error'


class String

  def to_boolean
    return false if self == false || self.nil? || self =~ (/(false|f|no|n|0)$/i)
    return true if self == true || self =~ (/(true|t|yes|y|1)$/i)
    raise ArgumentError.new("invalid value for Boolean: \"#{self}\"")
  end

end


class NilClass
  def to_boolean
    false
  end
end


module GitProc

  #
  # Provides Git configuration
  #
  class GitConfig

    def initialize(lib)
      @lib = lib
    end


    def [](key)
      value = config_hash[key]
      unless value
        value = @lib.command(:config, ['--get', key])
        value = nil if value.empty?
        config_hash[key] = value unless config_hash.empty?
      end
      value
    end


    def []=(key, value)
      @lib.command(:config, [key, value])
      config_hash[key] = value unless config_hash.empty?
      value
    end


    def set_global(key, value)
      @lib.command(:config, ['--global', key, value])
      config_hash[key] = value unless config_hash.empty?
      value
    end


    def gitlib
      @lib
    end


    def logger
      gitlib.logger
    end


    #
    # @return true if no value has been set; the value of the config otherwise
    def default_rebase_sync?
      val = self['gitProcess.defaultRebaseSync']
      val.nil? or val.to_boolean
    end


    def default_rebase_sync(re, global = true)
      if global
        set_global('gitProcess.defaultRebaseSync', re)
      else
        self['gitProcess.defaultRebaseSync'] = re
      end
    end


    def default_rebase_sync=(re)
      default_rebase_sync(re, false)
    end


    def master_branch
      @master_branch ||= self['gitProcess.integrationBranch'] || 'master'
    end


    def remote_master_branch
      remote.master_branch_name
    end


    def integration_branch
      remote.exists? ? remote_master_branch : self.master_branch
    end


    private

    def remote
      gitlib.remote
    end


    def config_hash
      @config_hash ||= {}
    end

  end

end
