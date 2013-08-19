require 'open-uri'
require 'nokogiri'

class RecipeScarfer
    def initialize(url)
        @doc = Nokogiri::HTML.parse(open(url).read)
    end
    
    def getSection(settings)
        begin   
            results = ''

            nodepath = settings['node_path']
            attr = settings['attribute']
            subs = settings['subs']     
            section_template = settings['section_template']
            item_template = settings['item_template']
            
            return results unless nodepath && nodepath != ''                        
            nodes = nodepath.start_with?('xpath:') ? \
                @doc.xpath(nodepath.gsub('xpath:', '').lstrip) : \
                @doc.css(nodepath.gsub('css:', '').lstrip)
                
            nodes.each do |a_tag|
                if attr && attr != ''
                    result = a_tag[attr]
                else
                    result = a_tag.content
                end
                if subs
                    subs.each do |a_sub|
                        result.gsub!(a_sub['token'], a_sub['replace'])
                    end
                end
                result = item_template.gsub('~', result) if item_template && item_template != ''
                results += result
            end
            
            return (section_template && section_template != '') ? section_template.gsub('~', results) : results
        rescue => e
            return e.message
            #e.backtrace
        end    
    end
end