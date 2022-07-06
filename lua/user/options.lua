o = vim.opt

o.backup = false                          
o.clipboard = "unnamedplus"               
o.cmdheight = 2                           
o.completeopt = { "menuone", "noselect" } 
o.conceallevel = 0                        
o.fileencoding = "utf-8"                  
o.hlsearch = true                         
o.ignorecase = true                       
o.mouse = "a"                             
o.pumheight = 10                          
o.showmode = false                        
o.showtabline = 2                         
o.smartcase = true                        
o.smartindent = true                      
o.splitbelow = true                       
o.splitright = true                       
o.swapfile = false                        
o.termguicolors = true                    
o.timeoutlen = 1000                       
o.undofile = true                         
o.updatetime = 300                        
o.writebackup = false                     
o.expandtab = true                        
o.shiftwidth = 2                          
o.tabstop = 2                             
o.cursorline = true                       
o.number = true                           
o.relativenumber = true                   
o.numberwidth = 4                         
o.signcolumn = "yes"                      
o.wrap = false                            
o.scrolloff = 8                           
o.sidescrolloff = 8
o.guifont = "monospace:h17"               

o.shortmess:append "c"

vim.cmd "set whichwrap+=<,>,[,],h,l"
vim.cmd [[set iskeyword+=-]]
vim.cmd [[set formatoptions-=cro]] 
