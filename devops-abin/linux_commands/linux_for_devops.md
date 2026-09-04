# Linux Commands
# 1.1 easy 

->Cd, ls, clear, pwd, 
-> ls -la
-> ls -ltr
-> rm, rmdir,
-> rm -r dir_name (it will remove the directory itself, -r ,means recursively)
-> touch file.txt(to create the text)
-> vi, vim 
-> cat file_name {to print the contents inside the etxt file}
-> echo "to print anything to the console" (to print anything to the terminal)
-> head, tail 
-> tail -f file_name (to print the last line)
-> less (to print the text file page by page )
-> more

# copy commands
-> cp, mv
-> cp source_path destination_path
-> mv {to move the contents permanently and also to rename it }
-> wc (word count)
    wc file_name
# cut
-> cut 
    cut -b 1 file_name (it will cut the words inside the file with specified byte siize )
# tee
-> tee (this command is used to print the input /op interminal as well as put that into a new file)
 echo "hi abin" | tee abin.txt

-> clear
-> sort (sort the words/letters inside the file in sorted order)
-> diff
 diff file_name1 file_name2


# link command (softlink and hardlink)
-> ln -s path_tothe_file_from/home/username/..  softlink_file
-> ln path_tothe_file_from/home/username/..   hardink-file
    the difference is that when the source file is deleted, the soflink-file will be deleted, but the hardlink file will be there forever


# advanced devops

# commands to check the process
-> ps -ef
-> docker ps 
-> nohup
-> top
-> htop
-> df -h (to check the disk usage )
-> free


-> proc
-> nproc

# find the file with filename under the / directory , ignores the error , it will be stored in the dev/null directory
-> find / -name  file_name 2>/dev/null 

-> ls -l (list all the files in long format)
-> ls -lrt (list all the file in long format, reverse order, with modification date as well)
-> jar xvf file_name (extract this jar file , x -extract, v - verbose, f - file )
-> 