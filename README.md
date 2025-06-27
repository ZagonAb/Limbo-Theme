# Limbo Theme for Pegasus Frontend

- **A custom interface for Pegasus Frontend inspired by the visual style of the game LIMBO.**

![screen](https://github.com/ZagonAb/Limbo-Theme/blob/a889d053d8a03c2276dd370669cb71e242004957/.meta/screnshots/screen.png)

## 🎮 Key Features

### Home Gallery
- Displays the last 15 games in a monochromatic style
- Shows games played in the last 7 days (minimum 1 minute of playtime)
- Complements with titles from api.allGames if there aren't enough recent games
- Detailed game information:
  - Title
  - Rating
  - Number of players
  - Last played
  - Playtime
  - Collection (shortname)
  - Description with AutoScroll
- Page indicators for navigation
- Options to launch games and manage favorites

### Top Navigation

1. **Collections**
   - List of available collections
   - GridView of games by collection
   - Visual identifier by collection
   - Ability to launch any game directly
   - Favorite management
   - Special label for favorite games

2. **All Games**
   - Complete game catalog
   - Visual collection identifier
   - Direct launch for any title
   - Favorite management

3. **Random Games**
   - Random selection of 10 titles
   - Direct game launch
   - No specific filters

4. **Resume**
   - Complete history of played games
   - Direct title launch
   - Favorite management

5. **Favorites**
   - Collection of favorite games
   - Direct launch of favorite games
   - Option to remove from favorites

## 🎨 Visual Effects

### LIMBO Style
- Dark theme
- Flicker effect
- Noise effect
- Desaturation/monochrome in images

### Technical Considerations
- Intensive use of ShaderEffect for visual effects
- ⚠️ **Performance Note**: Shader effects may impact resource usage

### Interface Elements
- Buttons with flicker effect when activated
- Dynamic Favorite indicator (-/+)
- Intuitive visual navigation system

# Monochrome RetroArch Icons:
- Icons used in this project from various contributors at [libretro](https://github.com/libretro/retroarch-assets/tree/master/xmb/monochrome/png) under [CC-BY-4.0](https://creativecommons.org/licenses/by/4.0/deed.en) license.

## 🛠️ Installation

[Download](https://github.com/ZagonAb/Limbo/archive/refs/heads/main.zip) and extract the theme to your [themes directory](http://pegasus-frontend.org/docs/user-guide/installing-themes). You can then select it in Pegasus' settings menu.

## 📜 License

<a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png" /></a><br /><a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/"></a>
