# A small DSL for helping parsing documents using Nokogiri::XML::Reader. The
# XML Reader is a good way to move a cursor through a (large) XML document fast,
# but is not as cumbersome as writing a full SAX document handler. Read about
# it here: http://nokogiri.org/Nokogiri/XML/Reader.html
#
# Just pass the reader in this parser and specificy the nodes that you are interested
# in in a block. You can just parse every node or only look inside certain nodes.
#
# A small example:
#
# Xml::Parser.new(Nokogiri::XML::Reader(open(file))) do
#   inside_element 'User' do
#     for_element 'Name' do puts "Username: #{inner_xml}" end
#     for_element 'Email' do puts "Email: #{inner_xml}" end
#
#     for_element 'Address' do
#       puts 'Start of address:'
#       inside_element do
#         for_element 'Street' do puts "Street: #{inner_xml}" end
#         for_element 'Zipcode' do puts "Zipcode: #{inner_xml}" end
#         for_element 'City' do puts "City: #{inner_xml}" end
#       end
#       puts 'End of address'
#     end
#   end
# end
#
# It does NOT fail on missing tags, and does not guarantee order of execution. It parses
# every tag regardless of nesting. The only way to guarantee scope is by using
# the `inside_element` method. This limits the parsing to the current or the named tag.
# If tags are encountered multiple times, their blocks will be called multiple times.


require 'nokogiri'

module Xml
  class Parser
    def initialize(node, &block)
      @node = node
      @node.each do |n|
        self.instance_eval &block
      end
    end

    def name
      @node.name
    end

    def inner_xml
      @node.inner_xml.strip
    end

    def outer_xml
      @node.outer_xml
    end

    def is_start?
      @node.node_type == Nokogiri::XML::Reader::TYPE_ELEMENT
    end

    def is_end?
      @node.node_type == Nokogiri::XML::Reader::TYPE_END_ELEMENT
    end

    def is_text?
      @node.node_type == Nokogiri::XML::Reader::TYPE_TEXT
    end

    def attribute(attribute)
      @node.attribute(attribute)
    end

    def value
      @node.value
    end

    def for_element(name, &block)
      return unless self.name == name and is_start?
      self.instance_eval &block
    end

    def for_element_text(name, &block)
      for_element name do
        inside_element do
          self.instance_eval(&block) if is_text?
        end
      end
    end

    def inside_element(name=nil, &block)
      return if @node.self_closing?
      return unless name.nil? or (self.name == name and is_start?)

      name = @node.name
      depth = @node.depth

      @node.each do
        return if self.name == name and is_end? and @node.depth == depth
        self.instance_eval &block
      end
    end
  end
end
