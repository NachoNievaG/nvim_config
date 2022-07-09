First personal nvim configuration
--
Heavily inspired in [this playlist](https://www.youtube.com/playlist?list=PLhoH5vyxr6Qq41NFL4GvhFp-WLd5xzIzZ), so huge thanks to [ChristianChiarulli](https://github.com/ChristianChiarulli)

To use this configuration please follow the steps:

## 1. (Optional) Make a copy of your current config
 
```
mv ~/.config/nvim ~/.config/nvim_backup
```

## 2. Clone into neovim config
```
$ git clone https://github.com/NachoNievaG/nvim_config ~/.config/nvim
```

## 3. Start neovim by running:
```
nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'
```

