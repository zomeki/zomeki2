# encoding: utf-8
module GpCalendar::GpCalendarHelper
  def localize_wday(style, wday)
    style.gsub('%A', t('date.day_names')[wday]).gsub('%a', t('date.abbr_day_names')[wday])
  end
end