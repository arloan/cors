# encoding: utf-8

APP_ROOTDIR = File.expand_path(File.dirname(__FILE__))
$: << APP_ROOTDIR

require 'common/app_const'
# require 'appconf'
# AppConfig.setup(AppConst::AppName, APP_ROOTDIR)
# APP_CONFIG = AppConfig.get_config(nil)

require 'app'

$stdout.sync = true unless $stdout.isatty
$stderr.sync = true unless $stderr.isatty
run Cuba
