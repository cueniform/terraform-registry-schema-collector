SHELL:=/bin/bash
CUE?=cue
default:
PROVIDER_SPACE_SEP_STRING=$(subst /, ,$(PROVIDER))
PROVIDER_NAMESPACE=$(word 1,$(PROVIDER_SPACE_SEP_STRING))
PROVIDER_IDENTIFIER=$(word 2,$(PROVIDER_SPACE_SEP_STRING))

schemata/providers/$(PROVIDER)/$(VERSION).json.zstd: build/schema.json.zstd | check-input-variables
	mkdir -p "$(dir $@)"
	mv --update --no-target-directory --verbose "$^" "$@"
build/schema.json.zstd: build/schema.json
	zstd --ultra -22 "$^" -o "$@" --force
build/schema.json: build/terraform/.terraform/
	terraform -chdir="build/terraform" providers schema -json >"$@"
build/terraform/.terraform/: build/terraform/.terraform/providers/registry.terraform.io/$(PROVIDER)/$(VERSION)/linux_amd64/terraform-provider-$(PROVIDER_IDENTIFIER)_v$(VERSION)
build/terraform/.terraform/providers/registry.terraform.io/$(PROVIDER)/$(VERSION)/linux_amd64/terraform-provider-$(PROVIDER_IDENTIFIER)_v$(VERSION): build/terraform/provider.tf.json build/terraform/.terraform.lock.hcl | check-input-variables
	terraform -chdir="build/terraform" init -lockfile=readonly -input=false -no-color
	mv "$$(find "$(dir $@)" -executable -type f -ls | sort -nk7 | awk 'END{for (i=1; i<11; i++) $$i="";  gsub(/^[[:space:]]+|[[:space:]]+$$/,""); print}')" "$@"
build/terraform/.terraform.lock.hcl: | check-input-variables
	$(CUE) export cueniform.com/collector/lib/templates --force \
	  --inject provider_version="$(VERSION)" --inject provider_identifier="$(PROVIDER)" \
	  -e lockfile_hcl.out --outfile "$@" --out text
build/terraform/provider.tf.json: | check-input-variables
	$(CUE) export cueniform.com/collector/lib/templates --force \
	  --inject provider_version="$(VERSION)" --inject provider_identifier="$(PROVIDER)" \
	  -e provider_tf.out --outfile "$@"

.PHONY: test
test:
	# Test build/terraform/provider.tf.json
	# Test build/terraform/.terraform.lock.hcl
	# Test build/terraform/.terraform/<some provider>
	# Test build/schema.json
	make -C system-test/scenario-1 check
	# Test build/schema.json.zstd
	make PROVIDER=hashicorp/null VERSION=3.2.1 build/schema.json.zstd
	diff -u test/build/schema.json <(zstd -dcf build/schema.json.zstd)
	make PROVIDER=hashicorp/null VERSION=3.2.1 schemata/providers/hashicorp/null/3.2.1.json.zstd
	diff -u test/build/schema.json <(zstd -dcf schemata/providers/hashicorp/null/3.2.1.json.zstd)
	make clean

.PHONY: check-input-variables
check-input-variables:
ifndef VERSION
	$(error VERSION is not set)
endif
ifndef PROVIDER
	$(error PROVIDER is not set)
endif

CLEANABLE_FILES+=build/terraform/provider.tf.json
CLEANABLE_FILES+=build/terraform/.terraform.lock.hcl
CLEANABLE_FILES+=build/terraform/.terraform/
CLEANABLE_FILES+=build/schema.json
CLEANABLE_FILES+=build/schema.json.zstd
clean:
	rm -rvf $(CLEANABLE_FILES)
default:
	false

MAKEFLAGS+=--no-builtin-rules
MAKEFLAGS+=--no-builtin-variables
MAKEFLAGS+=--no-print-directory
