## man

# pass (Password maneger)
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
-------------------------------------------------------------------------------
## auto_git
> command: a_git

flags:
$ a_git [flag]
> [push] git add, commit & push to all repos from "git_list" 
> [pull] git fetch & pull from all repos from "git_list" 

$ a_git [flag] [option]
> [-c] add cronjob, then enter [option]
    options:
    [push] add push cronjob
    [pull] add pull cronjob
    
    
