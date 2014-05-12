#
# conf.rb
#

=begin
= ruby/SDL�ȃQ�[���p config���j���[ 

==�T�v
config�ł��B�����p�ɍ���������Ȃ�ŁA�܂����N�Ƀe�X�g���Ă܂��� :-P
�[���P�N�قǂق��Ƃ�����Ŏ����ł��ǂ��킩��Ȃ��Ȃ��Ă܂��B

  menu = �Ȃ�Ƃ�����Ƃ��i�f�[�^�`�� ���Q�Ɓj
  screen = SDL::setVideoMode(...
  font = SDL::TTF.open(...
  conf = Config.new(screen,font,menu)

�ŏ��������A���Ƃ� conf.run �ŃC���^���N�e�B�u���O���t�B�J���ȃR���t�B�O��ʂ��B

==�ȒP�Ȏg�p��

  #SDL�̏���
  SDL.init(SDL::INIT_VIDEO)
  screen = SDL::setVideoMode(640,480,16,SDL::SWSURFACE)

  SDL::TTF.init
  font = SDL::TTF.open("font.ttf",24)

  #�R���t�B�O�f�[�^�̃��[�h
  open("savedata.dat","r") do |file|
    configdata = Marshal.load(file)
  end

  #���j���[�f�[�^�̒�`
  menu = [
    ["Level", ["Easy","Normal","Hard"] ],
    ["Music", [true,false] ],
    ["Sound", [true,false] ],
    [],
    ["#Exit"]
  ]

  #�R���t�B�O�I�u�W�F�N�g�̐���
  conf = Config.new(screen,font,menu,configdata)

  #�Q�[���{�̂̎��s...
    #�R���t�B�O���j���[�̎��s
    conf.run

  #�f�[�^�Z�[�u
  open("savedata.dat","w") do |file|
    Marshal.dump( conf.data, file )
  end

==���G�Ȏg�p��(���p��)
�ȉ��̂悤�Ȃ�肩���ŁA�R���t�B�O���j���[���u����q�v�ɂ��邱�Ƃ��ł��܂��B

  #�q�̒�`
  menu_sound = [
    ["Music", ["On","Off"] ],
    ["Sound", ["On","Off"] ],
    ["Sampling Rate", [44100,22050,11025] ]  #���l���n����̂ł� :)
    [],
    ["#Exit"]
  ]
  conf_sound = Config.new(screen,font,menu_sound)

  #�e�̒�`
  menu_main = [
    ["Level", ["Easy","Normal","Hard","Maniac"] ],
    [],
    ["Sound Settings", proc{ conf_sound.run }], #�������|�C���g
    [],
    ["#Exit"]
  ]
  conf_main = Config.new(screen,font,menu_main)

  #���s
  conf_main.run

�g�ݍ��݂�["#Exit"]�́A�ȉ��Ɠ����ł��B
  conf = Config.new(screen,font)
  conf.add_menuitem( ["Exit",proc{conf.quit}] )

==config��ʂł̑�����@
�㉺�ō��ڂ̑I���A���E�őI�����̑I���BSPACE�܂���ENTER�ō��ڂ̎��s�AESC�ŏI��

==TODO

*(�傫����s) <=����񂩁H
*(�L�[��`���ςɁi�����܂ł��邩�H�j)
* Choice�Ƀu���b�N��n���ƍ��ڕύX���ɑI�����ڂ�n���Ď��s���Ă����B���Ă�
    ["sound",["on","off], proc{|select| if select=="on" then flag_sound=true end} ]
  �Ƃ��B
* "#Key Config"�ŊȈՃL�[�R���t�B�O(Config::KeyConfig�̃I�u�W�F�N�g)�����s
* ���ݒ�

==���������ɂ���

*�f�[�^�Ƃ��Ĕz��@menu�ƃn�b�V��@selected�ƃO���[�o���ϐ�$CONF_xx�����B
*@menu�́A�N���X(���͍\����)Choice,Command,Space�̃I�u�W�F�N�g��v�f�Ɏ��z��B

�ȉ��͌Â����B

*�f�[�^�Ƃ��Ĕz��@menu�ƁA�n�b�V��@selected�ƁA�n�b�V��@configdata��3�����B
 (�����̓������Ƃ�̂��߂�ǂ��������ۂ�)
*@menu�̓v���O�����ɑ΂��ÓI�Ȃ̂ŁA�Z�[�u����Ƃ��ɂ�@configdata����������΂悢�B
*�Ƃ���ƁAinitialize�ɂ�menudata��configdata�����n����Ȃ�(@selected�͂���炩�琶������)
*�܂�menudata�݂̂����n����Ȃ��ꍇ������B

*run�ɂ����Ă�@selected�݂̂𑀍삵�Arun�̏I������@selected => @configdata�Ƃ���B(Config#renew_configdata)
 ����run����O�ɁA@selected��@configdata�ɓ������Ă���K�v������B
*$CONF_xx�������@configdata�͂���Ȃ��B
 �f�[�^�̃Z�[�u���@��V�����l����K�v����B
*["music"=>$CONF_music,"sound"=>$CONF_sound, ...]�݂����ȃn�b�V�����Z�[�u���ɍ쐬����

*initialize��load���킯��Ƃ�

=end

require "sdl"

class Config

private
  COL_HILIGHT = [0,255,255]
  COL_NORMAL  = [255,255,255]

  PREFIX = "CONF_"
  
  Choice = Struct.new("Choice",:name,:showname,:items,:loop)
  Command = Struct.new("Command",:name,:proc)
  Space = Struct.new("Space",:enlarge)

=begin  
==�f�[�^�`��
  menu = [
    ["display", ["window","fullscreen"]],
    ["sound", ["on","off","auto"]],
    ["music vol", ["off","10","20","30","40","50","60","70","80","90","100"], false ],
    [],
    ["key config",Proc.new{key_config}]
    ["#exit"]
  ]
�Ƃ��B

�e���j���[���ڂ́A
*Choice
   ["Music", [true,false]]
 �I���B��R�����Ń��[�v���邩�ǂ������w��ł��܂� ((-��߂邩��-))

 ���̏ꍇ�A$CONF_Music�Ƃ����ϐ���true��������false���Z�b�g����܂��B
 ��ʏ�ł́Atrue��"ON", false��"OFF"�ƕ\������܂��i�ݒ�\�j�B

 ����āAChoice�̍��ږ��ɂ͔��p�p�����Ƌ󔒁A`_'�ȊO�̕����͎g���܂���B�󔒂�'_'�ɕϊ�����܂��B

 ��:
   ["MUSIC VOL",[0,10,20,(�ȗ�),90,100 ]]  #=> $CONF_MUSIC_VOL = 0 ��
*Command  
   ["key config", proc{key_config} ]
 space�܂���enter�������ꂽ�Ƃ���Proc�����s
*Space
   []�܂���[nil]
 ��s�B
*Exit
   ["#exit"]�܂���["#EXIT"]�܂���["#Exit"]
 �I�����ꂽ�Ƃ��Ƀ��j���[���I��

�̂ǂꂩ���w�肵�܂��B

Choice�̑I�����ɂ�String�̑��AFixnum�����g���܂��i�\������.to_s���Ă���̂Łj�B
Choice,Command�̍��ږ���String�����g���܂���(����ȊO�̂��̂�n����ArgumentError���������܂�)�B

Choice�̍��ږ��͏d��������ׂ��ł͂���܂���i�d�������Config#[]�Ƃ�Config#data�ō��邱�ƂɂȂ�ł��傤�j�B
=end

  # ��̃t�H�[�}�b�g�ɏ]�����z����󂯎��A
  # �K�؂ȃI�u�W�F�N�g(Choice,Command,Space)��Ԃ��B
  # �����@selected,$CONF_xx������������B
  def menuitemize(item)
    case item.size
    when 0
      Space.new(false)
    
    when 1
      case item[0]
      when nil
        Space.new(false)
      when "#exit"
        Command.new("exit",proc{quit})
      when "#EXIT"
        Command.new("EXIT",proc{quit})
      when "#Exit"
        Command.new("Exit",proc{quit})
      else 
        raise "invalid menu item:#{item.inspect}"
      end
      
    when 2
      if item[0]==nil then  #�傫���󔒁i�������j
        Space.new(item[1])
      elsif item[1].is_a? Proc then
	raise ArgumentError,"title of a Command must be String" unless item[0].is_a? String
        Command.new(item[0],item[1])
      else
        ret = Choice.new(quote_space(item[0]), item[0], item[1], true)
	@selected[ret.name] = 0
	instance_eval("$#{PREFIX}#{ret.name} = ret.items[0]") # $CONF_music = ret.items[0]
        ret
      end
    when 3
      ret = Choice.new(quote_space(item[0]), item[0], item[1], item[2])
      @selected[ret.name] = 0
      instance_eval("$#{PREFIX}#{ret.name} = ret.items[0]") # $CONF_music = ret.items[0]
      ret
    end
  end

  #�󔒂��X�y�[�X�ɁA�L���������Ă���G���[
  def quote_space(name)
    raise ArgumentError,"title of Choice must be String" unless name.is_a? String
    if name=~/[^A-Za-z0-9_ ]/ then
      raise ArgumentError,"you can use only A-Z,a-z,0-9,`_' and space for a title of Choice."
    end
    name.gsub(/ /,"_")
  end

  # @selected -> $CONF_xx
  # (run�̏I�����Ɏg��)
  def renew_configdata
    @menu.each do |item|
      if item.is_a? Choice then
        # $CONF_music = item.items[@selected['music']]
	instance_eval("$#{PREFIX}#{item.name} = item.items[@selected[item.name]]")
      end
    end
  end
  
public

=begin
==�N���X���\�b�h
--- initialize(screen,font[,menudata])
    Config�N���X�̃I�u�W�F�N�g�𐶐����ĕԂ��܂��B

    screen�ɂ�SDL��screen���Afont�ɂ�SDL::TTF�I�u�W�F�N�g���A
    menudata�ɂ̓R���t�B�O���j���[�̃��j���[�f�[�^���w�肵�܂��i((<�f�[�^�`��>))���Q�Ɓj�B

    menudata���ȗ������ꍇ�́AConfig#run���ĂԑO�ɕK��Config#add_menuitem(s)�ɂ�胁�j���[�f�[�^��^���Ȃ���΂����܂���B
=end
  def initialize(*args)
    raise ArgumentError,"wrong # of arguments" if args.size<2 || args.size>4
    #screen
    @screen = args[0]

    #font
    @font = args[1]
    
    #view
    @margin_top  = 32
    @margin_left = 32
    @line_height = @font.textSize("jpfM")[1] * 1.5
    @true_string = "ON"
    @false_string= "OFF"
    @ondraw = proc{|screen,dt| screen.fillRect(0,0,@screen.w,@screen.h,[0,0,0]) }

    #model
    @selected = {}
    @configdata = {}
    
    #(menudata)
    @menu = []
    if args.size >= 3 then
      args[2].each do |item|
        @menu << menuitemize(item)
      end
    end
  end

  attr_accessor :margin_top,:margin_left,:line_height

=begin   
==���\�b�h
--- margin_top
--- margin_left
--- line_height
    ���ꂼ��A�R���t�B�O��ʂ̏�̗]���A���̗]���A�P�s�̍�����\���܂��B������ł��܂��B�f�t�H���g�ł�
      margin_top  = 32
      margin_left = 32
      line_height = (������"pjfM"�����݂̃t�H���g�ŕ`�悵���Ƃ��̍���) * 1.5
    �ƂȂ��Ă��܂��B�i�P�ʁFpixel�j

--- add_menuitem(item)
    �V�������j���[�A�C�e��item��ǉ����܂��Bitem��Array�ł��i((<�f�[�^�`��>))���Q�Ɓj�B
--- add_menuitems(items)
    �����̃��j���[�A�C�e��items(Array)��ǉ����܂��B�i�Q�ƁF((<�f�[�^�`��>))�j
--- quit
    ���s���̃R���t�B�O���j���[���I�����܂��BCommand�`���̃��j���[�A�C�e���Ŏg���܂��i((<�f�[�^�`��>))���Q�Ɓj�B
--- on_draw{|screen,dt| ... }
    ��ʂ̏����������Ɏ��s����鏈�����w�肵�܂��B���̏����̓��[�v���Ɏ��s����A���̏����̂��Ƃɕ������`�悳��܂��B
    dt�͑O��Ăяo��������̌o�ߎ���(ms)�ł��B

    �g�p��:
      conf.on_draw{|screen,dt|
        screen.fillRect(0,0,screen.w, screen.h,[255,255,255])
      }     
--- true_string(str)
--- false_string(str)
    Choice�̑I������true/false���w�肵���Ƃ��ɕ\������镶������w�肵�܂��B
    �f�t�H���g�ł͂��ꂼ��"ON","OFF"�ł��B
=end

  def add_menuitem(item)
    raise ArgumentError,"#{item} is not an Array" if !item.is_a? Array
    raise ArgumentError,"wrong # of arguments" if item.size>3
    @menu << menuitemize(item)
  end

  def add_menuitems(items)
    items.each do |item|
      add_menuitem(item)
    end
  end

  def quit
    @running=false
  end

  def on_draw(&block)
    @ondraw = block
  end

  def true_string(str)
    @true_string = str
  end
  def false_string(str)
    @false_string = str
  end
  
=begin
--- run
    �R���t�B�O���j���[�����s���܂��B�����((<config��ʂł̑�����@>))���Q�Ƃ��Ă��������B

    �܂��A���݂̎d�l�ł͎��s����ƃL�[���s�[�g���I�t�ɂȂ�܂��B���ӂ��Ă��������B
=end

  def run
    #data check
    if @menu.size == 0 then
      raise "no menudata for configuration"
    end
    if @menu.select{|item|item.is_a? Space}.size == @menu.size then
      raise "menudata must not all Space"
    end

    #set cursor
    cursor = 0
    while @menu[cursor].is_a? Space
      cursor+=1
    end

    margin = @font.textSize("< ")[0]      #=> [wid,hei][0] = wid.
    before = now = SDL.getTicks
    SDL::Key::enableKeyRepeat(500,80)
    @running = true
    
    while @running
      
      #event check
      while (event=SDL::Event2.poll)
        case event
        when SDL::Event2::Quit
          return nil
          
        when SDL::Event2::KeyDown
          #key check
          case event.sym
          when SDL::Key::UP
            cursor-=1 
            cursor = @menu.size-1 if cursor<0
            redo if @menu[cursor].is_a? Space
            
          when SDL::Key::DOWN
            cursor+=1 
            cursor = 0 if cursor>@menu.size-1
            redo if @menu[cursor].is_a? Space
            
          when SDL::Key::LEFT
            break if @menu[cursor].is_a? Command
	    item = @menu[cursor]
            @selected[item.name]-=1
            if @selected[item.name]<0 then
              @selected[item.name] = (item.loop) ? (item.items.size-1) : (0)
            end
            
          when SDL::Key::RIGHT
            break if @menu[cursor].is_a? Command
	    item = @menu[cursor]
            @selected[item.name]+=1
            if @selected[item.name] > item.items.size-1 then
              @selected[item.name] = (item.loop) ? (0) : (item.items.size-1)
            end

          when SDL::Key::RETURN, SDL::Key::SPACE
            @menu[cursor].proc.call if @menu[cursor].is_a? Command
            
          when SDL::Key::ESCAPE
            renew_configdata
            return nil   #exit menu.
            
          end
        end
      end

      #---drawing
      #drawing back
      now = SDL.getTicks
      @ondraw.call(@screen, now-before)
      before = now

      #drawing menu
      @menu.each_with_index do |item,i|
        case item
        when Space
          next
        when Command
          color = (i==cursor) ? COL_HILIGHT : COL_NORMAL
          @font.drawBlendedUTF8(@screen, item.name, @margin_left, @margin_top+i*@line_height, *color)
        when Choice
          choice=""
          if i==cursor then
            choice += "< " if @selected[item.name]>0 || item.loop
            choice += quote_tf(item.items[@selected[item.name]]).to_s
            choice += " >" if @selected[item.name]<item.items.size-1 || item.loop
            color = COL_HILIGHT
            m = (@selected[item.name]>0 || item.loop) ? margin : 0
          else
            choice = quote_tf(item.items[@selected[item.name]]).to_s
            color = COL_NORMAL
            m = 0
          end
          @font.drawBlendedUTF8(@screen, item.showname, @margin_left,    @margin_top+i*@line_height, *color)
          @font.drawBlendedUTF8(@screen, choice,        (@screen.w/2)-m, @margin_top+i*@line_height, *color)
        end
      end
      
      #flip
      @screen.flip
    end

    SDL::Key::disableKeyRepeat
    renew_configdata
  end

  # true/false => @true_string/@false_string
  def quote_tf(a)
    if a==true then
      @true_string
    elsif a==false then
      @false_string
    else
      a
    end
  end

=begin
--- savedata
    �R���t�B�O�f�[�^��Marshal�\�ȃI�u�W�F�N�g�ɕϊ��������̂�Ԃ��܂��B(���݂̎����ł́AHash���Ԃ���܂�)

    Config.initialize��Config#add_menuitems���Ń��j���[�f�[�^���Z�b�g���Ă���Ăяo���Ă��������B
    ((-�Ƃ����̂́A$CONF_xx�̂����A���j���[�f�[�^�ɂ�����̂����Z�[�u���Ȃ�����ł��B-))

--- loaddata(data)
    Config#savedata���Ԃ����I�u�W�F�N�g��ǂݍ��݂܂��Bdata�������ɕs�K��(�܂茻�݂̎����ł́AHash�ȊO)�Ȏ���
    �������܂���B

    Config.initialize��Config#add_menuitems���Ń��j���[�f�[�^���Z�b�g���Ă���Ăяo���Ă��������B
    ((-�Ƃ����̂́A���j���[�f�[�^���Z�b�g���鎞�Ɂu�ǂ��I�񂾂��v�Ƃ�����񂪃��Z�b�g����邩��ł��B
    ����͒������Ƃ���Β�����̂ł����A�R�[�h���������G�ɂȂ�̂Ŏd�l�Ƃ��Ă��܂��B-))
=end

  def savedata
    ret = {}
    @menu.each do |item|
      if item.is_a? Choice then
	# ret['music']=$CONF_music
	instance_eval("ret['#{item.name}']=$#{PREFIX}#{item.name}")
      end
    end
    ret
  end

  #savedata => $CONF_xx, @selected
  def loaddata(savedata)
    return unless savedata.is_a? Hash
      
    #savedata => $CONF_xx
    savedata.each_key do |key|
      quote_space(key) rescue next   #skip if `key' is invalid for a title of a Choice
      # $CONF_music = savedata['music']
      instance_eval("$#{PREFIX}#{key} = savedata['#{key}']")
    end
    
    # $CONF_xx => @selected
    @menu.each do |item|
      if item.is_a? Choice then
	# @selected['music'] = item.items.index( $CONF_music ) || 0 if $CONF_music!=nil
	instance_eval("@selected[item.name] = item.items.index( $#{PREFIX}#{item.name} )||0 if $#{PREFIX}#{item.name}!=nil")
      end
    end
  end
  
end


#test
if __FILE__==$0 then
  #init view
  SDL.init(SDL::INIT_VIDEO)
  screen = SDL::setVideoMode(640,480,16,SDL::SWSURFACE)

  #init font
  SDL::TTF.init
  font = SDL::TTF.open("boxfont2.ttf",24)


  conf1 = Config.new(screen, font, [
    ["music vol", ["off","10","20",30,"40","50","60","70","80","90","100"], false ],
    ["sound", [true,false]],
    [nil],
    ["#exit"],
  ], {"sound"=>"auto"})

  conf = Config.new(screen, font, [
    ["display", ["window","fullscreen"], true ],
    [],
    ["sound setting",proc{conf1.run}],
    ["key config",proc{} ],
    [],
    ["#Exit"]
  ], {"display"=>"fullscreen"})  

  #load
  #open("_junk.dat","rb"){|f| conf.loaddata( Marshal.load(f) ) }
  
  conf.on_draw{|screen,dt| screen.fillRect(0,0,640,480,[0,128,0])}
  conf.run

  p $CONF_sound
  p $CONF_music_vol

  #save
  #open("_junk.dat","wb"){|f| f.write(Marshal.dump( conf.savedata )) }
    
end

