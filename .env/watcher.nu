watch ../. --glob=**/*.zig {
	|_| clear ; zig build | echo ; if $env.LAST_EXIT_CODE == 0 {
		zig build run | echo "" 
	} 
}


