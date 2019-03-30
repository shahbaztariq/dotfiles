[ -n "$PS1" ] && source ~/.bash_profile;

if [ $TILIX_ID ] || [ $VTE_VERSION ]; then
	source /etc/profile.d/vte.sh
fi