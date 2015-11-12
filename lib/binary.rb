#!/usr/bin/env ruby

def processType(first, second)
    puts 'processType............'
    puts first
    puts second
    ename = File.extname(first)
    ename2 = File.extname(second)
    if ename != ename2
        puts ename
        puts ename2
        puts 'WARN !!!!!!'
        return nil
    end
    case ename
    when ".iso"
        `bash lib/processIso.sh #{first} #{second}`;
    when ".rpm"
        `bash lib/processRpm.sh #{first} #{second}`;
    when ".war"
        `bash lib/processWarJar.sh #{first} #{second}`;
    when ".jar"
        `bash lib/processWarJar.sh #{first} #{second}`;
    when ".zip"
        `bash lib/processZip.sh #{first} #{second}`;
    when ".gz"
        `bash lib/processGz.sh #{first} #{second}`;
    when ".tar"
        `bash lib/processTar.sh #{first} #{second}`;
    else
        return nil
    end

    return [first + '.DIR', second + '.DIR']
end

def binaryProcess(items)
    result = []
    items.each do |item|
        unless item.nil? || result.push(processType(item[0], item[1]))
        end
    end
    return result
end

def binaryDiff(first, second)
    if !first.nil? && !second.nil?
        output = `bash lib/binaryDiff.sh #{first} #{second}`;
        result = []
        i = 0
        output.split("\n").each do |item|
            #result[i] = item.split(' ').delete_if{ |i| i =~ /Binary|files|Files|and|differ/ }
            ret = []
            f = ''
            s = ''
            item.split(' ').each do |elem|
                if elem == 'Binary' or elem == 'files' or elem == 'Files'
                    next
                end
                if elem == 'and'
                    ret << f
                    f = 'X'
                    next
                elsif f == '' and f != 'X'
                    f = elem
                    next
                elsif f != '' and f != 'X'
                    f = f + '\\ ' + elem
                    next
                end

                if elem == 'differ'
                    ret << s
                    s = 'X'
                    next
                elsif s == '' and s != 'X'
                    s = elem
                    next
                elsif f != '' and s != 'X'
                    s = s + '\\ ' + elem
                    next
                end
            end
            result[i] = ret
            i = i + 1
        end
        return result
    end
end

def binary(items)
    items.each do |item|
        unless item.nil? || binary(binaryProcess(binaryDiff(item[0],item[1])))
        end
    end
end

binary([[ARGV[0],ARGV[1]]])


