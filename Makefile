TF := $(or $(shell command -v tofu),$(shell command -v terraform))

.PHONY: help validate deploy test destroy

help:
	@echo "make validate   check format and syntax of both roots"
	@echo "make deploy     apply azure/, then confluent/"
	@echo "make test       run the token and produce test on the VM"
	@echo "make destroy    destroy confluent/, then azure/"

validate:
	@for d in azure confluent; do \
	  $(TF) -chdir=$$d init -backend=false -input=false >/dev/null && \
	  $(TF) -chdir=$$d validate && $(TF) -chdir=$$d fmt -check || exit 1; \
	done

deploy:
	scripts/deploy.sh

test:
	scripts/test-on-vm.sh

destroy:
	scripts/destroy.sh
