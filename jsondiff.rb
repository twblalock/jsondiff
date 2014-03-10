# TODO differentiate between having a key with a null value, and not even having the key
# TODO user-configurable column width

module JsonDiff
    COLOR_BLACK = "\033[30m"
    COLOR_RED = "\033[31m"
    INDENT_NUM_SPACES = 2
    NULL_VALUE = "NULL" # used when a key exists but the value is null

    def self.diff(a, b)
        return compare(nil, a, b)
    end

    def self.valuesMatch(a, b)
        return a == b && a.class == b.class
    end

    def self.compare(key, a, b, indent = 0)
        numMismatches = 0
        if a.instance_of?(Hash) && b.instance_of?(Hash)
            numMismatches = compareHashes(key, a, b, indent)
        elsif a.instance_of?(Array) && b.instance_of?(Array)
            numMismatches = compareArrays(key, a, b, indent)
        else
            isMismatch = !valuesMatch(a, b)
            if isMismatch
                numMismatches += 1
            end
            printValues(key, a, b, isMismatch, indent)
        end

        return numMismatches
    end

    def self.compareHashes(key, a, b, indent)
        numMismatches = 0

        allKeys = []
        if !a.nil?
            allKeys.concat(a.keys)
        end
        if !b.nil?
            allKeys.concat(b.keys)
        end
        allKeys.uniq!

        printStartHash(key, a, b, indent)

        allKeys.each do |key|
            aval = nil
            if !a.nil? && a.has_key?(key)
                aval = a[key].nil? ? NULL_VALUE : a[key]
            end

            bval = nil
            if !b.nil? && !b.nil? && b.has_key?(key)
                bval = b[key].nil? ? NULL_VALUE : b[key]
            end

            numMismatches += compare(key, aval, bval, indent + 1)
        end

        printEndHash(key, a, b, indent)

        return numMismatches
    end

    def self.compareArrays(key, a, b, indent)
        numMismatches = 0

        printStartArray(key, a, b, indent)

        totalLength = 0
        if !a.nil?
            totalLength = a.length
        end
        if !b.nil?
            if b.length > totalLength
                totalLength = b.length
            end
        end

        totalLength.times do |i|
            aval = nil
            if !a.nil? && a.length > i
                aval = a[i].nil? ? NULL_VALUE : a[i]
            end

            bval = nil
            if !b.nil? && b.length > i
                bval = b[i].nil? ? NULL_VALUE : b[i]
            end

            numMismatches += compare(key, aval, bval, indent + 1)
        end

        printEndArray(key, a, b, indent)

        return numMismatches
    end

    def self.printColumns(col1, col2, indent, color = COLOR_BLACK)
        pad = ""
        indent.times do
            INDENT_NUM_SPACES.times do
                pad += " "
            end
        end
        printf("%s%-40s%s%-8s%s%s%s\n", color, "#{pad}#{col1}", COLOR_BLACK, "|", color, "#{pad}#{col2}", COLOR_BLACK)
    end

    def self.printValues(key, a, b, isMismatch, indent)
        color = COLOR_BLACK
        if isMismatch
            color = COLOR_RED
        end

        as = genString(key, a)
        bs = genString(key, b)

        # Add the line offset
        numLines = (as.lines.count > bs.lines.count) ? as.lines.count : bs.lines.count
        while as.lines.count < numLines
            as += "\n"
        end
        while bs.lines.count < numLines
            bs += "\n"
        end

        alines = as.split("\n")
        blines = bs.split("\n")
        numLines.times do |i|
            printColumns(alines[i], blines[i], indent, color)
        end
    end

    def self.genString(key, value)
        if value.nil?
            return ""
        end

        s = ""
        if !key.nil?
            s += "\"#{key}\": "
        end

        if value.instance_of?(String)
            s += "\"#{value}\""
        elsif value.instance_of?(Hash) || value.instance_of?(Array)
            s += JSON.pretty_generate(value)
        else
            s += "#{value}"
        end

        return s
    end

    def self.genStartEnd(key, value, suffix, prependKey = true)
        if value.nil?
            return ""
        end

        s = suffix
        if prependKey && !key.nil?
            s = "\"#{key}\": #{s}"
        end

        return s
    end

    def self.printStartHash(key, a, b, indent)
        printColumns(genStartEnd(key, a, "{"), genStartEnd(key, b, "{"), indent)
    end

    def self.printEndHash(key, a, b, indent)
        printColumns(genStartEnd(key, a, "}", false), genStartEnd(key, b, "}", false), indent)
    end

    def self.printStartArray(key, a, b, indent)
        printColumns(genStartEnd(key, a, "["), genStartEnd(key, b, "["), indent)
    end

    def self.printEndArray(key, a, b, indent)
       printColumns(genStartEnd(key, a, "]", false), genStartEnd(key, b, "]", false), indent)
    end
end
