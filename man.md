## man

# Password maneger
> comand: pass

# Option 1#- 1 element in "file_list"
$ pass 
> Then enter secret code

# Option 2#- more then 1 element in "file_list"
> [arg] the number of the element in "file_list" starting from 1
$ pass [arg]
> Then enter secret code

# Option 3#- flags:
> [-f] workin with file outside "file_list"
$ pass -f <secret_file_path>
> Then enter secret code
    
> [-d!] delete "file_list" & the program it self
$ pass -d!
