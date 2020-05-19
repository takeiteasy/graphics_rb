#!/usr/bin/ruby

lines = `ctags -x --c-kinds=+p -u build/graphics.h`.split("\n")
enum_stash, all_enums = [], {}
struct_stash, all_structs = nil, {}
all_prototypes = []
enum_active, struct_active = false, false

lines.each_with_index do |line, idx|
  /^(?<name>\S+)\s*(?<type>\S+)\s*(?<line>\d+)\s*(?<file>\S+)\s(?<defn>[^\n]+)/ =~ line
  obj = {}
  obj[:name] = name
  obj[:type] = type
  obj[:defn] = defn
  
  struct_active = false if struct_active and type != 'member'

  case type
  when 'enumerator'
    enum_active = true
    enum_stash << obj
  when 'typedef'
    next unless enum_active
    enum_list_active = false
    all_enums[name] = enum_stash.clone
    enum_stash.clear
  when 'struct'
    struct_active = true
    struct_stash = name
    all_structs[name] = []
  when 'member'
    next unless struct_active
    all_structs[struct_stash] << obj
  when 'prototype'
    all_prototypes << obj
  end
end

class String
  def to_PascalCase
    self.split('_').map(&:capitalize).join('')
  end
end

INT_MAX = 4294967295

def RGBA r, g, b, a
  (a << 24) ^ -(INT_MAX + 1) | r << 16 | g << 8 | b
end

all_callbacks, enum_map, output = [], {}, {}

output['ENUMS'] = all_enums.map do |k, v|
  name = k.to_PascalCase
  enum_map[k] = name
  out = "  #{name} = enum(\n\t"
  v.each_with_index do |vv, i|
    out << "\t :" + vv[:name]
    out << case vv[:defn]
           when /^#{vv[:name]} = \(+unsigned/
             a, r, g, b = vv[:defn].scan(/\((\d+)\)/).flatten.map(&:to_i)
             ', ' + RGBA(r, g, b, a).to_s
           when /^#{vv[:name]} = (0x)?(\d+)/
             ", #{$1}#{$2}"
           else
             ', ' + i.to_s
           end
    out << ",\n\t" unless i == v.length - 1
  end
  out << ")"
end

output['STRUCTS'] = all_structs.map do |k, v|
  out = "  class #{k[0...-2].to_PascalCase} < FFI::Struct\n  \tlayout\t"
  v.each_with_index do |vv, i|
    type = case vv[:defn]
      when /\S+\(\*#{vv[:name]}\)\([^\)]+\);/, /(\s\*|\*\s)#{vv[:name]}/
        ':pointer'
      else # Could need changing if member is struct or enum
        /^((unsigned )?(\S+))/ =~ vv[:defn]
        ':' + $3
      end
    out << ":#{vv[:name]}, #{type}"
    out << ",\n\t\t\t\t\t\t" unless i == v.length - 1
  end
  out << "\n  end"
end

callback_map = []
output['CALLBACKS'] = []
output['FUNCTIONS'] = all_prototypes.map do |v|
  /^(extern )?(?<ret>\S+) ([^\(])+\((?<args>.*)\);$/ =~ v[:defn]
  type = case ret
    when '_Bool'
      'int'
    when /\*/
      'pointer'
    else
      ret
    end
  args = args.split(';').map(&:strip)
  if args.length > 1
    tmp = args.select{ |i| i[/(extern )?\S+ #{v[:name]}/] }
    if tmp.empty?
      args = args[0]
    else
      args = tmp[0].gsub(/^(extern )?\S+ \S+\(/, '')[0...-1]
    end
  else
    args = args[0]
  end
  arg_parts = args.scan(/((\S+\(\*\S+\)\([^\)]+\))|\.{3}|((struct|unsigned|const) )?\S+ \S+),?/).map {|x| x[0]}
  unless arg_parts.length == 1 and arg_parts[0] == 'void'
    args = arg_parts.map do |x|
      case x
        when /(\S+)\(\*(\S+)\)\(([^\)]+)\)/
          cb_ret  = $1
          cb_name = $2
          cb_args = $3.split(', ').map do |vv|
            case vv
            when /\*/
              ':pointer'
            when /^_Bool/
              ':int'
            when /([A-Z_]+)/
              enum_map[$1]
            else
              ':' + vv.split(' ')[0]
            end
          end
          if cb_name =~ /(\S+)_cb/
            cb_name = $1 + '_callback'
          else # TODO: Modify header to have all callbacks suffixed with "_cb"
            cb_name = v[:name].end_with?('callback') ? v[:name] : v[:name] + '_callback'
          end
          unless callback_map.include? cb_name
            output['CALLBACKS'] << "  callback :#{cb_name}, [#{cb_args.join(', ')}], :#{cb_ret}"
            callback_map << cb_name
          end
          ':' + cb_name
        when /\*/
          ':pointer'
        when /^_Bool/
          ':int'
        when /^([A-Z_]+)/
          enum_map[$1]
        else
          if x == '...'
            ':varargs'
          else
            case x.split(' ')[-1].delete(',')
            when 'col', 'fg', 'bg'
              ':long'
            else
              /^(((struct|unsigned|const) )?(\S+))/ =~ x
              ':' + $4
            end
          end
        end
    end
  end
  "  attach_function :#{v[:name]}, [#{args.join(', ')}], :#{type}"
end

template = File.read('graphics_template.rb')
output.each do |k, v|
  template = template.gsub '$' + k, v.join("\n")
end
puts template
