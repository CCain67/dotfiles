#!/bin/sh
#--------------------------------------------------------------------------------------------------------
# This is a python script designed to extract the color scheme for a wallpaper from pywal
# and apply the scheme to several applications: zathura, sublime text, jupyter notebooks,
# firefox, and others.
#
# Here is a dictionary of the colors applied:
#
# color0 | color8:  black  | grey
# color1 | color9:  red    | light red
# color2 | color10: green  | light green
# color3 | color11: yellow | light yellow
# color4 | color12: blue   | light blue
# color5 | color13: purple | light purple
# color6 | color14: aqua   | light aqua
# color7 | color15: silver | light silver
#
# Here are the required packages for this to work:
# Sublime:
# - ColorSchemeEditor package from bobef
#
# Jupyter
# - jupyterthemes (install via pip)
#--------------------------------------------------------------------------------------------------------



# required libraries
#--------------------------------------------------------------------------------------------------------
import pywal # for generating colors
import numpy as np # rgb fiddling
from lxml import etree # for assigning colors
#--------------------------------------------------------------------------------------------------------



# helpful functions
#--------------------------------------------------------------------------------------------------------

# rgb and hex functions
def rgb_to_hex(r,g,b):
    h='#'
    for c in [r,g,b]:
        h += hex( int(min(255,c)) )[2:].zfill(2)
    return h

def hex_to_rgb(hex):
    h = hex.lstrip('#')
    h_rgb = np.array([int(h[i:i+2], 16) for i in (0, 2 ,4)])
    return h_rgb

def hex_to_rgb_str(hex_color):
    return str(hex_to_rgb(hex_color)[0])+','+str(hex_to_rgb(hex_color)[1])+','+str(hex_to_rgb(hex_color)[2])

def shift_hex(hex,scale):
    return rgb_to_hex(*(hex_to_rgb(hex)*scale).astype(int))

# helpful file strings
dark = 'dark_None_None_1.1.0.json'
light = 'light_None_None_1.1.0.json'

# get the json color file
def get_color_file(image,color):
    s = image.split('/')
    W = s[-1].split('.')
    name = W[0]
    pic = W[1]

    file = '_'
    for i in range(1,len(s)-1):
        file+=s[i]+'_'
    file = file + name + '_' + pic + '_'
    if color == 'd':
        return file+dark
    elif color == 'l':
        return file+light
#--------------------------------------------------------------------------------------------------------



# generate required colors
#--------------------------------------------------------------------------------------------------------
condition = str(input('Enter "wallpaper" or "theme": '))

while condition not in {'wallpaper','theme'}:
    condition = str(input('Enter "wallpaper" or "theme": '))

if condition == 'wallpaper':
    # get image and colors
    image = pywal.wallpaper.get('/home/chase/.cache/wal/')
    T = str(input('Enter l (light) or d (dark): '))
    file = get_color_file(image,T)
    colors = pywal.colors.file('/home/chase/.cache/wal/schemes/'+file)

if condition == 'theme':
    print('Available choices: \n')
    print('1. Dark theme')
    print('2. Light theme')
    print('3. Dark-dkeg theme')
    print('4. Light-dkeg theme')
    print('5. Custom theme')
    print('6. Mixed BG\n')
    T = str(input('Enter a number: '))
    while T not in {'1','2','3','4','5','6'}:
        T = str(input('Enter number: '))
    theme = str(input('Enter a theme: '))
    if T == '1':
        colors = pywal.colors.file('/home/chase/dotfiles/colorschemes/dark/'+theme+'.json')
    if T == '2':
        colors = pywal.colors.file('/home/chase/dotfiles/colorschemes/light/'+theme+'.json')
    if T == '3':
        colors = pywal.colors.file('/home/chase/dotfiles/colorschemes/dkeg_fixed/dkeg-'+theme+'.json')
    if T == '4':
        colors = pywal.colors.file('/home/chase/dotfiles/colorschemes/dkeg_fixed_light/dkeg-'+theme+'_light.json')
    if T == '5':
        colors = pywal.colors.file('/home/chase/dotfiles/colorschemes/custom/'+theme+'.json')
    if T == '6':
        colors = pywal.colors.file('/home/chase/dotfiles/colorschemes/mixed_bg/'+theme+'.json')

# get specific colors from dictionary
bg = colors['special']['background']
fg = colors['special']['foreground']
input_color = shift_hex(bg,1.15) # shift bg for input areas
bg_dark = shift_hex(bg,.75) # shift bg for darker areas
bg_light = shift_hex(bg,1.25) # shift bg for darker areas
fg_dark = shift_hex(fg,.75) # shift bg for darker areas
fg_light = shift_hex(fg,1.25) # shift bg for darker areas
cursor = colors['special']['cursor']
color = [ colors['colors']['color'+str(i)] for i in range(16) ]
#--------------------------------------------------------------------------------------------------------


# change zathura colors
#--------------------------------------------------------------------------------------------------------
with open('/home/chase/.config/zathura/zathurarc','w') as z:
    z.write('set font '+'"Whyosevka Bold 11"'+'\n')
    z.write('set recolor true'+'\n')
    z.write('set recolor-darkcolor "'+fg+'" \n')
    z.write('set recolor-lightcolor "'+bg+'" \n')
    z.write('set inputbar-fg "'+color[1]+'" \n')
    z.write('set inputbar-bg "'+bg+'" \n')
    z.write('set default-fg "'+fg+'" \n')
    z.write('set default-bg "'+bg+'" \n')
    z.write('set statusbar-fg "'+color[6]+'" \n')
    z.write('set statusbar-bg "'+bg+'" \n')
    z.close()
#--------------------------------------------------------------------------------------------------------


# change sublime colors !!this needs the ColorSchemeEditor package from bobef
#--------------------------------------------------------------------------------------------------------
'''
with open('/home/chase/dotfiles/pywal_extend/templates/sublime/TemplateUserColor.tmTheme') as f:
    # import xml
    t = etree.fromstring(f.read().encode('utf-8'))
    f.close()

    # assign colors
    t[0][9][1].text = bg
    t[0][9][3].text = color[1]
    t[0][9][5].text = fg
    t[0][9][7].text = color[0]
    t[0][9][9].text = fg
    t[0][11][0][1][1].text = bg
    t[0][11][0][1][3].text = color[5]
    t[0][11][0][1][5].text = fg
    t[0][11][0][1][7].text = color[3]
    t[0][11][0][1][9].text = color[3]
    t[0][11][0][1][11].text = color[2]
    t[0][11][1][5][1].text = color[5]
    t[0][11][2][5][1].text = color[3]
    t[0][11][3][5][1].text = color[5]
    t[0][11][4][5][1].text = color[5]
    t[0][11][5][5][1].text = color[5]
    t[0][11][6][5][1].text = color[14]
    t[0][11][7][5][1].text = color[2]
    t[0][11][8][5][1].text = color[13]
    t[0][11][9][5][1].text = color[10]
    t[0][11][10][5][1].text = color[7]
    t[0][11][11][5][1].text = color[13]
    t[0][11][12][5][1].text = color[14]
    t[0][11][13][5][1].text = color[12]
    t[0][11][14][5][1].text = color[11]
    t[0][11][15][5][1].text = color[9]
    t[0][11][16][5][1].text = color[9]
    t[0][11][17][5][1].text = color[9]
    t[0][11][18][5][1].text = color[9]
    t[0][11][19][5][1].text = color[2]
    t[0][11][20][5][1].text = color[9]
    t[0][11][21][5][1].text = color[13]
    t[0][11][22][5][1].text = color[14]
    t[0][11][23][5][1].text = color[9]
    t[0][11][24][5][3].text = color[13]
    t[0][11][25][5][1].text = color[9]
    t[0][11][26][5][3].text = color[10]
    t[0][11][27][5][3].text = color[14]
    t[0][11][28][5][1].text = color[11]
    t[0][11][29][5][1].text = color[2]
    t[0][11][30][5][1].text = color[9]
    t[0][11][31][5][1].text = color[2]
    t[0][11][32][5][1].text = color[9]
    t[0][11][33][5][1].text = color[2]
    t[0][11][33][5][3].text = color[5]
    t[0][11][34][5][1].text = color[11]
    t[0][11][35][5][1].text = color[2]
    t[0][11][36][5][1].text = color[14]
    t[0][11][37][5][1].text = color[12]
    t[0][11][38][5][1].text = color[12]
    t[0][11][39][5][1].text = color[12]
    t[0][11][40][5][1].text = fg
    t[0][11][41][5][1].text = color[2]
    t[0][11][41][5][3].text = color[0]

    with open('/home/chase/.config/sublime-text-3/Cache/UserColors/UserColor.tmTheme','w') as f:
        f.write(etree.tostring(t).decode('utf-8'))
        f.close()
'''
#--------------------------------------------------------------------------------------------------------


# change jupyter colors !!this needs the jupyterthemes package
#--------------------------------------------------------------------------------------------------------
'''
with open('/home/chase/.jupyter/custom/custom.css','w') as f:
    # write in the variables
    f.write(':root { \n')
    f.write('\t --bg: '+bg+'; \n')
    f.write('\t --fg: '+fg+'; \n')
    f.write('\t --input_color: '+input_color+'; \n')
    f.write('\t --color0: '+color[0]+'; \n')
    f.write('\t --color1: '+color[1]+'; \n')
    f.write('\t --color2: '+color[2]+'; \n')
    f.write('\t --color3: '+color[3]+'; \n')
    f.write('\t --color4: '+color[4]+'; \n')
    f.write('\t --color5: '+color[5]+'; \n')
    f.write('\t --color6: '+color[6]+'; \n')
    f.write('\t --color7: '+color[7]+'; \n')
    f.write('\t --color8: '+color[8]+'; \n')
    f.write('\t --color9: '+color[9]+'; \n')
    f.write('\t --color10: '+color[10]+'; \n')
    f.write('\t --color11: '+color[11]+'; \n')
    f.write('\t --color12: '+color[12]+'; \n')
    f.write('\t --color13: '+color[13]+'; \n')
    f.write('\t --color14: '+color[14]+'; \n')
    f.write('\t --color15: '+color[15]+'; \n')
    f.write('} \n')

    with open('/home/chase/dotfiles/pywal_extend/templates/jupyter/templatecustom.css') as g:
        f.write(g.read())
        f.close()
'''
#--------------------------------------------------------------------------------------------------------


# change firefox colors
#--------------------------------------------------------------------------------------------------------
'''
with open('/home/chase/.mozilla/firefox/4oa45wja.default-release/chrome/userChrome.css','w') as f:
    # write in the variables
    f.write(':root { \n')
    f.write('\t --bg: '+bg+'; \n')
    f.write('\t --fg: '+fg+'; \n')
    f.write('\t --color0: '+bg_dark+'; \n')
    f.write('\t --input_color: '+input_color+'; \n')
    f.write('\t --color1: '+color[1]+'; \n')
    f.write('\t --color2: '+color[2]+'; \n')
    f.write('\t --color3: '+color[3]+'; \n')
    f.write('\t --color4: '+color[4]+'; \n')
    f.write('\t --color5: '+color[5]+'; \n')
    f.write('\t --color6: '+color[6]+'; \n')
    f.write('\t --color7: '+color[7]+'; \n')
    f.write('\t --color8: '+color[8]+'; \n')
    f.write('\t --color9: '+color[9]+'; \n')
    f.write('\t --color10: '+color[10]+'; \n')
    f.write('\t --color11: '+color[11]+'; \n')
    f.write('\t --color12: '+color[12]+'; \n')
    f.write('\t --color13: '+color[13]+'; \n')
    f.write('\t --color14: '+color[14]+'; \n')
    f.write('\t --color15: '+color[15]+'; \n')
    f.write('} \n')

    with open('/home/chase/dotfiles/pywal_extend/templates/firefox/userChromeTemplate.css') as g:
        f.write(g.read())
        f.close()
'''

with open('/home/chase/.mozilla/firefox/lhqqwrox.default-release/chrome/userContent.css','w') as f:
    # write in the variables
    f.write(':root { \n')
    f.write('\t --bg: '+bg+'; \n')
    f.write('\t --fg: '+fg+'; \n')
    f.write('\t --fg_dark: '+fg_dark+'; \n')
    f.write('\t --color0: '+bg_dark+'; \n')
    f.write('\t --input_color: '+input_color+'; \n')
    f.write('\t --color1: '+color[1]+'; \n')
    f.write('\t --color2: '+color[2]+'; \n')
    f.write('\t --color3: '+color[3]+'; \n')
    f.write('\t --color4: '+color[4]+'; \n')
    f.write('\t --color5: '+color[5]+'; \n')
    f.write('\t --color6: '+color[6]+'; \n')
    f.write('\t --color7: '+color[7]+'; \n')
    f.write('\t --color8: '+color[8]+'; \n')
    f.write('\t --color9: '+color[9]+'; \n')
    f.write('\t --color10: '+color[10]+'; \n')
    f.write('\t --color11: '+color[11]+'; \n')
    f.write('\t --color12: '+color[12]+'; \n')
    f.write('\t --color13: '+color[13]+'; \n')
    f.write('\t --color14: '+color[14]+'; \n')
    f.write('\t --color15: '+color[15]+'; \n')
    f.write('} \n')

    with open('/home/chase/dotfiles/pywal_extend/templates/firefox/userContentTemplate.css') as g:
        f.write(g.read())
        f.close()
#--------------------------------------------------------------------------------------------------------


# change kde colors
#--------------------------------------------------------------------------------------------------------
with open('/home/chase/.local/share/color-schemes/pywal_colors.colors','w') as f:
    # write in the variables
    f.write('[ColorEffects:Disabled] \n')
    f.write('Color=56,56,56 \n')
    f.write('ColorAmount=0 \n')
    f.write('ColorEffect=0 \n')
    f.write('ContrastAmount=0.65 \n')
    f.write('ContrastEffect=1 \n')
    f.write('IntensityAmount=0.1 \n')
    f.write('IntensityEffect=2 \n')

    f.write('\n')

    f.write('[ColorEffects:Inactive] \n')
    f.write('ChangeSelectionColor=true \n')
    f.write('Color=112,111,110 \n')
    f.write('ColorAmount=0.025 \n')
    f.write('ColorEffect=2 \n')
    f.write('ContrastAmount=0.1 \n')
    f.write('ContrastEffect=2 \n')
    f.write('Enable=true \n')
    f.write('IntensityAmount=0 \n')
    f.write('IntensityEffect=0 \n')

    f.write('\n')

    f.write('[Colors:Button] \n')
    f.write('BackgroundAlternate='+hex_to_rgb_str(bg)+'\n')
    f.write('BackgroundNormal='+hex_to_rgb_str(bg)+'\n')
    f.write('DecorationFocus='+hex_to_rgb_str(color[6])+'\n')
    f.write('DecorationHover='+hex_to_rgb_str(color[6])+'\n')
    f.write('ForegroundActive='+hex_to_rgb_str(fg)+'\n')
    f.write('ForegroundInactive='+hex_to_rgb_str(fg)+'\n')
    f.write('ForegroundLink='+hex_to_rgb_str(color[4])+'\n')
    f.write('ForegroundNegative='+hex_to_rgb_str(color[1])+'\n')
    f.write('ForegroundNeutral='+hex_to_rgb_str(color[3])+'\n')
    f.write('ForegroundNormal='+hex_to_rgb_str(fg)+'\n')
    f.write('ForegroundPositive='+hex_to_rgb_str(color[2])+'\n')
    f.write('ForegroundVisited='+hex_to_rgb_str(color[5])+'\n')

    f.write('\n')

    f.write('[Colors:Selection] \n')
    f.write('BackgroundAlternate='+hex_to_rgb_str(bg)+'\n')
    f.write('BackgroundNormal='+hex_to_rgb_str(bg)+'\n')
    f.write('DecorationFocus='+hex_to_rgb_str(color[6])+'\n')
    f.write('DecorationHover='+hex_to_rgb_str(color[6])+'\n')
    f.write('ForegroundActive='+hex_to_rgb_str(fg)+'\n')
    f.write('ForegroundInactive='+hex_to_rgb_str(fg)+'\n')
    f.write('ForegroundLink='+hex_to_rgb_str(color[4])+'\n')
    f.write('ForegroundNegative='+hex_to_rgb_str(color[1])+'\n')
    f.write('ForegroundNeutral='+hex_to_rgb_str(color[3])+'\n')
    f.write('ForegroundNormal='+hex_to_rgb_str(fg)+'\n')
    f.write('ForegroundPositive='+hex_to_rgb_str(color[2])+'\n')
    f.write('ForegroundVisited='+hex_to_rgb_str(color[5])+'\n')

    f.write('\n')

    f.write('[Colors:Tooltip] \n')
    f.write('BackgroundAlternate='+hex_to_rgb_str(bg)+'\n')
    f.write('BackgroundNormal='+hex_to_rgb_str(bg)+'\n')
    f.write('DecorationFocus='+hex_to_rgb_str(color[6])+'\n')
    f.write('DecorationHover='+hex_to_rgb_str(color[6])+'\n')
    f.write('ForegroundActive='+hex_to_rgb_str(fg)+'\n')
    f.write('ForegroundInactive='+hex_to_rgb_str(fg)+'\n')
    f.write('ForegroundLink='+hex_to_rgb_str(color[4])+'\n')
    f.write('ForegroundNegative='+hex_to_rgb_str(color[1])+'\n')
    f.write('ForegroundNeutral='+hex_to_rgb_str(color[3])+'\n')
    f.write('ForegroundNormal='+hex_to_rgb_str(fg)+'\n')
    f.write('ForegroundPositive='+hex_to_rgb_str(color[2])+'\n')
    f.write('ForegroundVisited='+hex_to_rgb_str(color[5])+'\n')

    f.write('\n')

    f.write('[Colors:View] \n')
    f.write('BackgroundAlternate='+hex_to_rgb_str(bg)+'\n')
    f.write('BackgroundNormal='+hex_to_rgb_str(bg)+'\n')
    f.write('DecorationFocus='+hex_to_rgb_str(color[6])+'\n')
    f.write('DecorationHover='+hex_to_rgb_str(color[6])+'\n')
    f.write('ForegroundActive='+hex_to_rgb_str(fg)+'\n')
    f.write('ForegroundInactive='+hex_to_rgb_str(fg)+'\n')
    f.write('ForegroundLink='+hex_to_rgb_str(color[4])+'\n')
    f.write('ForegroundNegative='+hex_to_rgb_str(color[1])+'\n')
    f.write('ForegroundNeutral='+hex_to_rgb_str(color[3])+'\n')
    f.write('ForegroundNormal='+hex_to_rgb_str(fg)+'\n')
    f.write('ForegroundPositive='+hex_to_rgb_str(color[2])+'\n')
    f.write('ForegroundVisited='+hex_to_rgb_str(color[5])+'\n')

    f.write('\n')

    f.write('[Colors:Window] \n')
    f.write('BackgroundAlternate='+hex_to_rgb_str(bg)+'\n')
    f.write('BackgroundNormal='+hex_to_rgb_str(bg)+'\n')
    f.write('DecorationFocus='+hex_to_rgb_str(color[6])+'\n')
    f.write('DecorationHover='+hex_to_rgb_str(color[6])+'\n')
    f.write('ForegroundActive='+hex_to_rgb_str(fg)+'\n')
    f.write('ForegroundInactive='+hex_to_rgb_str(fg)+'\n')
    f.write('ForegroundLink='+hex_to_rgb_str(color[4])+'\n')
    f.write('ForegroundNegative='+hex_to_rgb_str(color[1])+'\n')
    f.write('ForegroundNeutral='+hex_to_rgb_str(color[3])+'\n')
    f.write('ForegroundNormal='+hex_to_rgb_str(fg)+'\n')
    f.write('ForegroundPositive='+hex_to_rgb_str(color[2])+'\n')
    f.write('ForegroundVisited='+hex_to_rgb_str(color[5])+'\n')

    f.write('\n')

    f.write('[General] \n')
    f.write('ColorScheme=pywal_custom \n')
    f.write('Name=pywal_custom \n')
    f.write('shadeSortColumn=true \n')

    f.write('\n')

    f.write('[KDE] \n')
    f.write('contrast=4 \n')

    f.write('\n')

    f.write('[WM] \n')
    f.write('activeBackground='+hex_to_rgb_str(bg)+'\n')
    f.write('activeBlend=235,219,178 \n')
    f.write('activeForeground='+hex_to_rgb_str(fg)+'\n')
    f.write('inactiveBackground='+hex_to_rgb_str(bg)+'\n')
    f.write('inactiveBlend=60,56,54 \n')
    f.write('inactiveForeground='+hex_to_rgb_str(fg)+'\n')

    f.close()
#--------------------------------------------------------------------------------------------------------

print('Done!')
