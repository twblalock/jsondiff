# the goal: print both jsons side-by-side and highlight the differences
# test representation doesn't matter -- only the JSON objects are compared

require "json"

require "./jsondiff"

def readJson(filename)
    begin
        return JSON.parse(File.read(filename))
    rescue Exception => e
        puts "error parsing file: #{filename}: #{e}"
        puts e.backtrace
        exit 1
    end
end

if ARGV.length < 2
    puts "Usage: ruby jsondiff.rb file1 file2"
    exit 1
end

FILE1 = ARGV[0]
FILE2 = ARGV[1]

# TODO print output side-by-side?
a = readJson(FILE1)
b = readJson(FILE2)
numMismatches = JsonDiff.diff(a, b)
if numMismatches > 0
    exit 1
end
