# Base for one-shot service objects. Subclasses accept collaborators via
# keyword arguments and expose a single public `#call`. Dependencies that
# are expected to vary (model classes, policies) should be injectable via
# kwargs with a sensible default so tests can swap them without stubbing.
class ApplicationService
  def self.call(**args)
    new(**args).call
  end
end
