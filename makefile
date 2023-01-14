start_node:
	iex --erl "-gcounter type $(NAME) -gcounter id $(ID)" --sname $(NAME)@localhost -S mix