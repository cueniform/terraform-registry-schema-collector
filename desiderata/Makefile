include Makefile.shared
default:
.PHONY: FORCE

include Makefile.PROVIDERS

# We're assuming that we'll match the stem 'provider.namespace.*.type.*.cue',
# such that neither namespace nor type contain periods, spaces; or anything
# filesystem-relevant. Revisit this as needed.
provider.namespace.%.cue: SPACE_SEP=$(subst ., ,$(*))
provider.namespace.%.cue: NAMESPACE=$(word 1,$(SPACE_SEP))
provider.namespace.%.cue: check=$(word 2,$(SPACE_SEP))
provider.namespace.%.cue: TYPE=$(word 3,$(SPACE_SEP))
provider.namespace.%.cue: FORCE
	$(MSG)
	@[ "$(check)" = "type" ] || { echo "Mismatched stem ('$*' in '$@'); exiting"; exit 1; }
	curl --silent --show-error --location --fail \
	  registry.terraform.io/v1/providers/$(NAMESPACE)/$(TYPE)/versions \
	| $(CUE) import json: - \
	  --outfile "$@" \
	  --package desiderata \
	  --path provider: --path $(NAMESPACE): --path $(TYPE): \
	  --force
	$(CUE) vet -c "$@"

FILES=$(sort $(PROVIDERS))
# Don't forget to run the tests when changing the number of buckets!
BUCKETS:=1 2 3 4 5
NUM_BUCKETS:=$(words $(BUCKETS))
$(foreach B,$(BUCKETS),$(eval BUCKET-$(B)!=echo $(FILES) | xargs -n1 | awk '!((NR+$(B))%$(NUM_BUCKETS))'))
$(foreach B,$(BUCKETS),$(eval bucket-$(B): $$(BUCKET-$(B))))

.PHONY: all
all: $(FILES) # Don't use this outside of testing, use bucket-* instead
	$(MSG)

bucket-%: FORCE
	$(MSG)

.PHONY: debug
debug:
	# PROVIDER: $(PROVIDERS)
	# BUCKETS: $(BUCKETS)
	# NUM_BUCKETS: $(NUM_BUCKETS)
	# BUCKET-0: $(BUCKET-0)
	# BUCKET-1: $(BUCKET-1)
	# BUCKET-2: $(BUCKET-2)
	# BUCKET-3: $(BUCKET-3)
	# BUCKET-4: $(BUCKET-4)
	# BUCKET-5: $(BUCKET-5)
	# BUCKET-6: $(BUCKET-6)

default:
	false
