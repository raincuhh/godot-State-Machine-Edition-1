class_name StateMachine
extends Node

#
# made by raincuh
#
# A simple state machine system for managing states in a game, inspired by a C++ state machine system.
# This implementation allows you to define states with their corresponding enter, leave, and normal behaviors,
# and handles transitions between states. It is particularly useful for managing player states like idle,
# move, jump, and more.
#
# Example usage:
# ```gdscript
# var stateMachine: StateMachine = StateMachine.new()
#
# func _ready() -> void:
#     var states = ["idle", "move", "jump", "fall", "dash", "slide", "duck"]
#
#     for state in states:
#         stateMachine.add_states(
#             state,
#             Callable(self, "st_%s" % state),
#             Callable(self, "st_enter_%s" % state),
#             Callable(self, "st_leave_%s" % state)
#         )
#     stateMachine.set_initial_state(Callable(self, "st_idle"))
#
# func st_idle():
#     pass
#
# func st_enter_idle():
#     pass
#
# func st_leave_idle():
#     pass
# ```
#
# Properties:
# - `states`: A dictionary containing all the registered states (`Callable` objects) and their corresponding `StateFlows`.
# - `stateNames`: A dictionary that maps `Callable` states to their string names.
# - `currentState`: The current state that the state machine is in.
# - `previousState`: The previous state before transitioning to the current state.
#
# Methods:
#
# - `update(delta: float) -> void`:
#   The update loop that should be called every frame. It checks the current state's `normal` behavior and handles transitions if needed.
#
#   Parameters:
#   - `delta`: The time elapsed since the last frame (used for frame-based updates).
#
# - `add_states(stName: String, normal: Callable, enterState: Callable, leaveState: Callable)`:
#   Registers a new state with its `normal`, `enterState`, and `leaveState` behaviors.
#
#   Parameters:
#   - `stName`: The string name of the state (e.g., "idle", "move").
#   - `normal`: The callable function for the state's `normal` behavior (called every frame).
#   - `enterState`: The callable function that runs when the state is entered.
#   - `leaveState`: The callable function that runs when the state is exited.
#
# - `change_state(state: Callable) -> void`:
#   Transitions to a new state if the state exists in the `states` dictionary.
#
#   Parameters:
#   - `state`: The `Callable` function representing the new state to transition to.
#
# - `set_state(state: StateFlows) -> void`:
#   Internal method to set the new current state and handle calling `enterState` and `leaveState` methods.
#
#   Parameters:
#   - `state`: The `StateFlows` object representing the new state's behaviors.
#
# - `set_initial_state(state: Callable)`:
#   Sets the initial state of the state machine.
#
#   Parameters:
#   - `state`: The `Callable` function representing the initial state.
#
# - `get_current_state()`:
#   Returns the current state's `Callable` function.
#
# - `get_current_state_name() -> String`:
#   Returns the string name of the current state, or "unknown state" if the state name is not found.
#
# Inner Class:
#
# - `StateFlows`:
#   A class that defines a state with three behaviors: `normal`, `enterState`, and `leaveState`.
#
#   Properties:
#   - `normal`: A `Callable` function representing the state's normal behavior (called every frame).
#   - `enterState`: A `Callable` function called when the state is entered.
#   - `leaveState`: A `Callable` function called when the state is exited.
#
#   Methods:
#   - `_init(normal: Callable, enterState: Callable, leaveState: Callable)`:
#     Constructor to initialize the state flows.
#
#     Parameters:
#     - `normal`: The callable function for the state's `normal` behavior.
#     - `enterState`: The callable function for the state's enter behavior.
#     - `leaveState`: The callable function for the state's leave behavior.

var states = {} # dictionary of states.
var stateNames = {}
var currentState: Callable
var previousState: Callable

func update(delta: float) -> void: # update loop.
	if currentState:
		var nextState = currentState.call(delta)
		if nextState and nextState != currentState: # checks if the next state is not the current state, if so then it changes state.
			change_state(nextState)

func add_states(stName: String, normal: Callable, enterState: Callable, leaveState: Callable):
	var stateFlow = StateFlows.new(normal, enterState, leaveState) # registering a state. normal(every frame), enter(1 time when you enter), leave(1 time when you leave)
	states[normal] = stateFlow # adds the registered stateflow inside the dictionary of states.
	stateNames[normal] = stName

func change_state(state: Callable) -> void:
	if states.has(state): # checks if the dictionary states has a specific stored state. if it does, then it calls set_state, on that specific state.
		call_deferred("set_state", states[state])

func set_state(state: StateFlows) -> void:
	if currentState:
		if states.has(currentState):
			var currentStateFlow = states[currentState] # selects the specific state flow from the dictionary that contains them.
			if currentStateFlow.leaveState: # then it checks if it has a leave state,
				currentStateFlow.leaveState.call() # and if it does then it invokes the method.
			previousState = currentState # then just sets the state as the previous state (for stuff).
	currentState = state.normal # then it sets the current state as the state thats being inputteds normal (normal is just what happens while the state is active).
	if state.enterState: # checks for a enterstate in the stateflow, if it has one, it invokes it.
		state.enterState.call()

func set_initial_state(state: Callable):
	if states.has(state):
		set_state(states[state])

func get_current_state():
	return currentState

func get_current_state_name() -> String:
	if stateNames.has(currentState):
		return stateNames[currentState]
	else:
		return "unknown state"

# stateflows is just a template for how a state ususally is
class StateFlows:
	var normal: Callable # a normal which is updated every process, this usually has the methods for switching to a different state.
	var enterState: Callable # a method that gets called once when you either change state or just initialize as a specific state.
	var leaveState: Callable # a method that gets called once when you either change state or just leave a specific state.

	func _init(normal: Callable, enterState: Callable, leaveState: Callable): # constructor.
		self.normal = normal
		self.enterState = enterState
		self.leaveState = leaveState
