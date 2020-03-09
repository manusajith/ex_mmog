defmodule ExMmog.Game.Actions do
  @callback join(binary, atom | pid | {atom, any} | {:via, atom, any}) :: any
  @callback view(atom | pid | {atom, any} | {:via, atom, any}) :: any
  @callback move(any, any, any) :: any
  @callback attack(any, atom | pid | {atom, any} | {:via, atom, any}) :: any

  defprotocol Dispatch do
    @doc """
    Perform the specified actions on the game state.
    """
    @spec perform(any) :: any
    def perform(action)
  end
end
