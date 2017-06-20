require 'state_machines/graphviz'

class StateMachine::YARD::Handlers::Transition
  def process
    if [StateMachines::Machine, StateMachines::Event, StateMachines::State].include?(owner.class)
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
  end
end

class StateMachine::YARD::Handlers::Machine
  def integration
    @integration ||= StateMachines::Integrations.match_ancestors(namespace.inheritance_tree(true).map(&:path))
  end
end
