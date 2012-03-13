desc "convert less documents to RTL"

namespace :assets do

  task :rtlize do
    base_dir = File.expand_path('../../../',__FILE__)
    source_dir = File.join(base_dir,'vendor','assets','stylesheets','twitter','bootstrap')
    target_dir = File.join(base_dir,'vendor','assets','stylesheets','twitter','bootstrap-rtl')
    Dir.glob(source_dir + '/*.less').each do |file|
      puts "Working on %s" % file
      css = File.open(file,'r'){|f| f.read }
      rtl_css = rtl_convert css
      target_file = File.join(target_dir, File.basename(file))
      File.open(target_file,'w'){|f| f.write rtl_css }
    end
  end

end

def rtl_convert(css)
  place_holder = '|====|'
  css.gsub! 'ltr', 'rtl'

  ltr_matches = css.scan /^([\n\s]*[^:\n\t\s\.\#\{\}]*(left|right)[^:]*:)|(:[^\w\.\#\{\}]*[^;\.\#\{\}]*(left|right)[^;]*;)/
  css_to_replace = ltr_matches.flatten.delete_if{|a| a.nil? || ['left','right'].include?(a) }
  css_to_replace.each do |match|
    next if match.include? 'right'
    css.gsub! match, (match.gsub 'left', place_holder)
  end
  css_to_replace.each do |match|
    next if match.include? 'left'
    css.gsub! match, (match.gsub 'right', 'left')
  end
  css.gsub! place_holder, 'right'

  quad_matches = css.scan /\d+[\w%]+\s\d+[\w%]+\s\d+[\w%]+\s\d+[\w%]+/
  quad_matches.each do |m|
    t, r, b, l = m.split ' '
    css.gsub! m, [t,l,b,r].join(' ')
  end
  return css
end