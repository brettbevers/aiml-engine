require 'find'

module AIML
  module Cache
  def self.dumping(aFilename,theGraphMaster)
    File.open(aFilename,'w') do |file|
      file.write(Marshal.dump(theGraphMaster,-1))
    end
  end

  def self.loading(aFilename)
    File.open(aFilename,'r') do |file|
      return Marshal.load(file.read)
    end rescue nil
  end
  end # module Cache

  module FileFinder
    # Returns an array of aiml files recursively found
    def self.find(ext, files_and_dirs)
      files_and_dirs = files_and_dirs.is_a?(Array) ? files_and_dirs : [files_and_dirs]
      files = []
      files_and_dirs.each{|file|
        if File.file?(file) && (file  =~ /.*\.#{ext}$/)
          files << file
          next
        end
        files += find(ext, Dir.glob("#{file}/*"))
      }
      files
    end

    def self.find_file(basename, files_and_dirs)
      files_and_dirs = files_and_dirs.is_a?(Array) ? files_and_dirs : [files_and_dirs]
      files_and_dirs.each{|file_or_dir|
        if File.file?(file_or_dir) && File.basename(file_or_dir) == basename
          return file_or_dir
        else
          Find.find(file_or_dir) do |file|
            return file if File.basename(file) == basename
          end
        end
      }
      nil
    end

    def self.find_aiml(files_and_dirs)
      find(:aiml, files_and_dirs)
    end

    def self.find_maps(files_and_dirs)
      find(:map, files_and_dirs)
    end

    def self.find_sets(files_and_dirs)
      find(:set, files_and_dirs)
    end

    def self.find_normalizations(files_and_dirs)
      find_file("normal.substitution", files_and_dirs)
    end

    def self.find_denormalizations(files_and_dirs)
      find_file("denormal.substitution", files_and_dirs)
    end

    def self.find_pdefaults(files_and_dirs)
      find(:pdefaults, files_and_dirs)
    end

    def self.find_properties(files_and_dirs)
      find(:properties, files_and_dirs)
    end
  end
end #module AIML
