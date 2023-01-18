# Gcounter

**Grow-only crdt counter with distributed Elixir**

## Running

### Running nodes

Run these commands on 3 different windows to simulate distributed nodes

```
make start_node target NAME=charlie target ID=2

make start_node target NAME=bob target ID=1

make start_node target NAME=alice target ID=0
```

**NAME** - Erlang Name of the node.

**ID** - ID of the node, used in the crdt state

### Functions

In the iex shell of each node, we can execute following functions

`Gcounter.Counter.increment` - This will increment the distributed counter by 1.

`Gcounter.Counter.value` - Will return the current counter value

**OUTPUT** - We can call increment on different nodes and see that `value` returns same counter value
eventually, with no centralized storage. Our grow-only crdt will merge correctly all the increments from different nodes.

### Reference
http://jtfmumm.com/blog/2015/11/17/crdt-primer-1-defanging-order-theory/

### TODO

- Adding and removal of nodes dynamically within a network
- Implement actual gossip protocol for inter-node communications 