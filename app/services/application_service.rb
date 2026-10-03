# Base class for one-shot service objects.
#
# Convention: subclasses accept their collaborators via keyword arguments in
# `initialize` and expose a single public `call` method. The class-level
# `.call(**args)` shortcut lets callers write `Thing::DoIt.call(x: 1)` instead
# of `Thing::DoIt.new(x: 1).call`.
#
# Dependencies that are expected to vary (e.g. model classes) should be
# injectable via kwargs with a sensible default pointing at the real class, so
# tests can swap them out without stubbing globals.
class ApplicationService
  def self.call(**args)
    new(**args).call
  end
end
