#!/usr/bin/env ruby
class Node
  attr_reader   :value, :children
  attr_accessor :freq, :children
  
  # initialize sets up a new Node 
  # with default values
  def initialize(value)
    @value = value
    @freq = 0
    @children = []
  end
  
  # add will create a node for the input value and add it as a child
  # if the value already exists as a child, it does nothing
  def add(value)
    return nil if has?(value)
    
    child = Node.new(value)
    @children << child
    return child
  end
  
  # get returns the child with the given value if it exists
  def get(value)
    @children.each { |child| return child if child.value == value }
    return nil
  end
  
  # has? returns whether this node has a child whose value == the input value
  def has?(value)
    return get(value) != nil
  end
end

class Trie
  # initialize sets up a new trie
  def initialize()
    # root is the base node in our trie
    @root = Node.new(nil)
  end
  
  def add_word(word)
    # set our starting node as the root
    node = @root
    
    # iterate, add each letter, and 
    # set the new node as the result of each added letter
    letters = word.chars
    letters.each { |c| node = add_char(c, node) }

    # the base is now the last letter of the word, 
    # so increment its frequency
    node.freq += 1
  end
    
  # add_char attempts to add the input c as a child to the input node
  def add_char(c, node)
    # if c is already a child, return its node
    return node.get(c) if node.has?(c)
    
    # otherwise, return the result of calling node.add (a new node)
    return node.add(c)
  end
  
  # get_word returns the node of the last letter of word if it is in the tree
  # returns nil if the given word is not in the tree
  def get_word(word)
    # start from the root and iterate down
    node = @root
    word.size.times { |i|
      # if our current letter doesnt exist as a child in our current node, the word is not in the trie
      return nil unless node.has?(word[i])
      node = node.get(word[i])
    }
    return node
  end
  
  def suggestions(prefix)
    node = get_word(prefix)
    return {} if node == nil
    
    # if we find a node, now we need to parse down the tree (DFS) and flatten it out
    # we don't need the last letter of the prefix because _parse is just going to add it again
    words = {}
    _parse(node, words, prefix[0..-2])
    
    # sort by most frequent words, descending
    words.sort_by{|k, v| v}
      .reverse
      .to_h
  end
  
  # _parse recursively goes through a trie 
  # and returns all the full words that are available
  def _parse(node, words, prefix)
    current = prefix + node.value
    words[current] = node.freq if node.freq > 0
    node.children.each { |child| _parse(child, words, current)}
  end
end

# main functionality steps:
# - construct Trie
# - ingest dictionary
# - take subset of Trie with given input prefix
# - return n highest valued words
trie = Trie.new()

# split each line and add the words
puts "Creating autocomplete dictionary"
IO.foreach("shakespeare-complete.txt") { |line| 
  # there is a better way of doing this but I'm not going to spend time on it
  # making everything lowercase for consistency's sake
  lines = line.split(/\W+/)
  lines.each {|word| 
    word.downcase!
    trie.add_word(word)}  
}
puts "Dictionary complete!"
puts ""

while true do

  puts "Enter word for autocompletion (or exit to kill the program): "
  
  text = gets.strip
  lines = text.split("\n")
  lines.each { |line| 
    exit if line.downcase == "exit"
    
    # make sure our input is long enough
    puts "Input too small; try again" if line.length < 2 
    break if line.length < 2
  
    # make it pretty by adding a line
    puts ""
    recs = trie.suggestions(line)
  
    # check the result size
    puts recs.size > 0 ? "Recommendations Found: " : "No Recommendations Found"
  
    # only show the top ten results
    max_recs = 25
    recs.each { |rec|
      break if max_recs <= 0
      puts "#{rec[0]} (#{rec[1]})"
      max_recs -= 1
    }
  }
  
  puts ""
  
end

