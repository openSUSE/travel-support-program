require "yard"
require "state_machine"
require "yard-state_machine"

class StateMachine::YARD::Handlers::Transition
  def process
    if [StateMachine::Machine, StateMachine::Event, StateMachine::State].include?(owner.class)
      options = {}

      # Extract requirements
      ast = statement.parameters.first
      ast.children.each do |assoc|
        # Skip conditionals
        next if %w(if :if unless :unless).include?(assoc[0].jump(:ident).source)

        options[extract_requirement(assoc[0])] = extract_requirement(assoc[1])
      end

      owner.transition(options)
    end
  end
end
