bqed: $(CBQN/BQN)
	CBQN/BQN bqed.bqn

CBQN/BQN:
	make -C CBQN

.PHONY: bqed
