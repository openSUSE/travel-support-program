# frozen_string_literal: true

require 'state_machines/graphviz'

# YARD embeds PNG files; the default renderer writes diagrams to standard output.
StateMachines::Machine.renderer = StateMachines::Graphviz::Renderer

class StateMachines::Yard::Handlers::Base
  alias tsp_extract_node_name extract_node_name

  def extract_node_name(ast)
    # Introduce support for syntax like:
    #   state_machine :state, initial: :incomplete
    # Without this patch, only this syntax would be recognized
    #   state_machine :state, :initial => :incomplete
    if ast.type == :label
      ast[0].to_sym
    else
      tsp_extract_node_name(ast)
    end
  end

  alias tsp_extract_node_names extract_node_names

  # Keep the plugin's positional signature for its existing callers.
  def extract_node_names(ast, convert_to_array = true) # rubocop:disable Style/OptionalBooleanParameter
    # YARD nodes inherit Array; literals must be interpreted before array contents.
    if ast.respond_to?(:type) && %i[symbol_literal string_literal label].include?(ast.type)
      name = extract_node_name(ast)
      convert_to_array ? [name] : name
    else
      tsp_extract_node_names(ast, convert_to_array)
    end
  end
end

class StateMachines::Yard::Handlers::Transition
  def process
    return unless [StateMachines::Machine, StateMachines::Event, StateMachines::State].include?(owner.class)

    options = {}

    # Extract requirements
    ast = statement.parameters.first
    ast.children.each do |assoc|
      # Skip conditionals
      next if %w[if :if unless :unless].include?(assoc[0].jump(:ident).source)

      options[extract_requirement(assoc[0])] = extract_requirement(assoc[1])
    end

    owner.transition(options)
  end

  alias tsp_extract_requirement extract_requirement

  def extract_requirement(ast)
    # Introduce support for syntax like:
    #   transition incomplete: :submitted
    # Without this patch, only this syntax would be recognized
    #   transition :incomplete => :submitted
    if ast.type == :label
      extract_node_name(ast)
    else
      tsp_extract_requirement(ast)
    end
  end
end

class StateMachines::Yard::Handlers::Machine
  def integration
    @integration ||= StateMachines::Integrations.match_ancestors(namespace.inheritance_tree(true).map(&:path))
  end
end
