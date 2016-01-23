use File::Find;
use Cwd;

my $local_dir = getcwd;
my %hash;
my %translate_hash;
my $now_count = 0;

# ��ʼ��ȡԴ�����е��ַ���
finddepth(\&wanted, "../src");

# ����ȡ�������ݽ�������
my @keys = sort { $hash{$b} <=> $hash{$a} } keys %hash;

# ��ʼ��ȡԭ��translate.conf�еĺ������
get_translate("../conf/msg_conf/translate.conf");

# ���
print "data: (\n";

# �����һЩ����̶�������
print "\t{\n\t\tsrc: \"^CL_RED^[Fatal Error]^CL_RESET^:\"\n\t\ttarget: \"^CL_RED^[���ش���]^CL_RESET^:\"\n\t},\n";
print "\t{\n\t\tsrc: \"^CL_RED^[Error]^CL_RESET^:\"\n\t\ttarget: \"^CL_RED^[����]^CL_RESET^:\"\n\t},\n";
print "\t{\n\t\tsrc: \"^CL_CYAN^[Debug]^CL_RESET^:\"\n\t\ttarget: \"^CL_CYAN^[����]^CL_RESET^:\"\n\t},\n";
print "\t{\n\t\tsrc: \"^CL_YELLOW^[Warning]^CL_RESET^:\"\n\t\ttarget: \"^CL_YELLOW^[����]^CL_RESET^:\"\n\t},\n";
print "\t{\n\t\tsrc: \"^CL_WHITE^[Notice]^CL_RESET^:\"\n\t\ttarget: \"^CL_WHITE^[��ʾ]^CL_RESET^:\"\n\t},\n";
print "\t{\n\t\tsrc: \"^CL_WHITE^[Info]^CL_RESET^:\"\n\t\ttarget: \"^CL_WHITE^[��Ϣ]^CL_RESET^:\"\n\t},\n";
print "\t{\n\t\tsrc: \"^CL_MAGENTA^[SQL]^CL_RESET^:\"\n\t\ttarget: \"^CL_MAGENTA^[���ݿ�]^CL_RESET^:\"\n\t},\n";
print "\t{\n\t\tsrc: \"^CL_GREEN^[Status]^CL_RESET^:\"\n\t\ttarget: \"^CL_GREEN^[״̬]^CL_RESET^:\"\n\t}";

# ��ʼ�����Դ���ж�ȡ��������
my $is_first = 0;
for (@keys){
	if (ignore($_) == 1) { next; }
	if ($is_first == 0){ print ",\n"; }
	my $translate = $translate_hash{$_};
	print "\t{\n\t\tsrc: $_\n\t\ttarget: \"$translate\"\n\t}";
	if ($is_first == 1){ $is_first = 0; }
}
print "\n)";

# ==================================================================

# ��ȡԭ���ĺ������
sub get_translate{
	my $confpath = @_[0];
	# ֻ�����ļ�
	if(-f "$local_dir/$confpath"){
		open(my $fh, '<', "$local_dir/$confpath") or die "Could not open file '$local_dir/$confpath' $!";
		my $info = "";
		
		while (my $row = <$fh>) {
			$info .= $row;
		}
		close $fh;
		
		my $count = 0;
		while ($info =~ /\t{\n\t\tsrc: (".*?")\n\t\ttarget: "(.*?)"\n\t(},|})/g) {
			$translate_hash{$1} = $2;
			$count += 1;
		}
		return $count;
	}
	return -1;
}

# ת����ɫ����
sub colormark($){
	my $rpl = @_[0];
	$rpl =~ s/\"CL_RESET\"/\^CL_RESET\^/g;
	$rpl =~ s/\"CL_CLS\"/\^CL_CLS\^/g;
	$rpl =~ s/\"CL_CLL\"/\^CL_CLL\^/g;
	$rpl =~ s/\"CL_BOLD\"/\^CL_BOLD\^/g;
	$rpl =~ s/\"CL_NORM\"/\^CL_NORM\^/g;
	$rpl =~ s/\"CL_NORMAL\"/\^CL_NORMAL\^/g;
	$rpl =~ s/\"CL_NONE\"/\^CL_NONE\^/g;
	$rpl =~ s/\"CL_WHITE\"/\^CL_WHITE\^/g;
	$rpl =~ s/\"CL_GRAY\"/\^CL_GRAY\^/g;
	$rpl =~ s/\"CL_RED\"/\^CL_RED\^/g;
	$rpl =~ s/\"CL_GREEN\"/\^CL_GREEN\^/g;
	$rpl =~ s/\"CL_YELLOW\"/\^CL_YELLOW\^/g;
	$rpl =~ s/\"CL_BLUE\"/\^CL_BLUE\^/g;
	$rpl =~ s/\"CL_MAGENTA\"/\^CL_MAGENTA\^/g;
	$rpl =~ s/\"CL_CYAN\"/\^CL_CYAN\^/g;
	return $rpl;
}

# �ж��Ƿ���Ҫ���������һ�е�conf��
sub ignore {
	my $rpl = @_[0];
	if ($rpl =~ /"EXPAND_AND_QUOTE\(PACKETVER\)"/){ return 1; }
	
	if ($rpl =~ /^"%s(\\n|)"(\s+|)$/){ return 1; }
	if ($rpl =~ /^"%d(\\n|)"(\s+|)$/){ return 1; }
	if ($rpl =~ /^"\\n"(\s+|)$/){ return 1; }
	return 0;
}

# ÿ�ζ�ȡ���ļ�ʱ�Ĵ���
# ===========================================================
# ���һ��ֻ��һ�����ݣ�û�в���
#         ShowStatus("Loading NPCs...\r");
# �������ֻ��һ�����ݣ��в���
#         ShowStatus("Loading NPC file: %s"CL_CLL"\r", file->name);
# ��������ɶ������ݹ��ɣ��в���
#         ShowInfo ("Done loading '"CL_WHITE"%d"CL_RESET"' NPCs:"CL_CLL"\n"
#                   "\t-'"CL_WHITE"%d"CL_RESET"' Warps\n"
#                   "\t-'"CL_WHITE"%d"CL_RESET"' Shops\n"
#                   "\t-'"CL_WHITE"%d"CL_RESET"' Scripts\n"
#                   "\t-'"CL_WHITE"%d"CL_RESET"' Spawn sets\n"
#                   "\t-'"CL_WHITE"%d"CL_RESET"' Mobs Cached\n"
#                   "\t-'"CL_WHITE"%d"CL_RESET"' Mobs Not Cached\n",
#                   npc_id - START_NPC_NUM, npc_warp, npc_shop, npc_script, npc_mob, npc_cache_mob, npc_delay_mob);
# ===========================================================
sub wanted {
	# ֻ�����ļ���Ŀ¼��������
	if(-f "$local_dir/$File::Find::name"){
		# ���ļ�
		open(my $fh, '<', "$local_dir/$File::Find::name") or die "Could not open file '$File::Find::name' $!";
		my $no_ending = 0;
		my $cache = "";
		
		# ��ʼ����ÿһ�е�����
		while (my $row = <$fh>) {
			# ȥ��ĩβ�Ļ���
			chomp $row;
			$row = colormark($row);
			if (ignore($row) == 1){
				next;
			}
			
			# �����Կ�������һ���ܲ�����ȡ������������
			if (($row =~ /(ShowDebug|ShowInfo|ShowError|ShowStatus|ShowSQL|ShowNotice|ShowWarning|ShowFatalError)(\s+|)\((\s+|)(".*?(?<!\\)")(\);|,)/i) && ($no_ending == 0)){
				# ����ܣ�����hash�����Ѿ��й�����ַ����ˣ���ô����
				if (exists$hash{'$4'}){
					next;
				}
				# ������뵽��ϣ��
				$hash{$4} = $now_count;
				# �����$now_count��Ϊֵ����ͷ���������õ�
				$now_count = $now_count + 1;
				# ����������һ��Ҳ�Ϳ���������
				next;
			}
			
			# �����ȡ����һ�е�ʱ�򣬷�����һ���ǲ������ģ���ô�Ͱ���һ�е�����һ�еĲ���
			if ($no_ending == 1){
				# �������Ǵ����ŵ�һ�еĻ�����ôִ������ξ����ǽ���һ�в�ȱ�Ĳ�����
				if ($row =~ /"(.*?)((?<!\\)",|"\);)/i){
					$cache .= $1;
					$cache = "\"".$cache."\"";
					if (exists$hash{'$cache'}){
						$cache = "";
						# ���Ϊ�Ѿ������ˣ��������ٶ������п��԰��������Ĺ���ȥƥ����
						$no_ending = 0;
						next;
					}
					$hash{$cache} = $now_count;
					$now_count = $now_count + 1;
					$cache = "";
					$no_ending = 0;
				}
				else {
					# ����������ţ���ô˵����û�꣬��ô��һ��ֻ����һ�е�һ���֣����Ǻ������б��
					$row =~ /"(.*?)(?<!\\)"$/i;
					$cache .= $1;
				}
				next;
			}
			
			# �����һ���Ǹ����������У���ô���Ϊ������ȡ�����п�������һ�е�һ����
			if ($row =~ /(ShowDebug|ShowInfo|ShowError|ShowStatus|ShowSQL|ShowNotice|ShowWarning|ShowFatalError)(\s+|)\((\s+|)"(.*?)(?<!\\)"(\s+|)$/i){
				$cache = $4;
				$no_ending = 1;
			}
		}
		close $fh;
	}
}