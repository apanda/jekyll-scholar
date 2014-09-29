module Jekyll
  class Scholar

    class BibliographyTag < Liquid::Tag
      include Scholar::Utilities

      def initialize(tag_name, arguments, tokens)
        super

        @config = Scholar.defaults.dup

        optparse(arguments)
      end

      def render(context)
        set_context_to context

        items = entries

        if cited_only?
          items = if skip_sort?
            cited_references.uniq.map do |key|
              items.detect { |e| e.key == key }
            end
          else
            entries.select do |e|
              cited_references.include? e.key
            end
          end
        end

        items = items.take(max.to_i) if limit_entries?

        #bibliography = items.each_with_index.map { |entry, index|
          #reference = bibliography_tag(entry, index + 1)
          ##puts entry['year']
          ##puts reference
          #if generate_details?
            #reference << link_to(details_link_for(entry),
              #config['details_link'], :class => config['details_link_class'])
          #end

          ##content_tag :li, reference
        #}#.join("\n")

        bib_by_year = {}
        items.each_with_index.each { |entry, index|
          reference = bibliography_tag(entry, index + 1)
          if generate_details?
            reference << link_to(details_link_for(entry),
              config['details_link'], :class => config['details_link_class'])
          end
          ref = content_tag :li, reference
          key = entry['year'].to_i
          bib_by_year[key] = bib_by_year.has_key?(key) ? bib_by_year[key].push(ref) : Array.new.push(ref)
        }

        bib_by_year.keys.sort{|a, b| a < b ? 1 : -1 }.map {|k|
            list_of_li = bib_by_year[k].join("\n")

            content_tag(:h2, k.to_s) + 
            content_tag(:ul, list_of_li,:class => config['bibliography_class'])
        }.join("\n")

      end
    end

  end
end

Liquid::Template.register_tag('bibliography', Jekyll::Scholar::BibliographyTag)
