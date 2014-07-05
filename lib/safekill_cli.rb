#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

class Safekill
  def initialize(*options)
    @options = options
  end

  def run
    exec_flag = @options.delete("-x")
    @regexp = @options.first
    if @regexp.to_s.empty?
      puts "正規表現を指定してください。"
      return
    end
    puts "【検索文字列】"
    puts @regexp
    puts

    process_ids = ps_aux
    if process_ids.empty?
      return
    end

    command = "sudo kill -9 #{process_ids.join(' ')}"
    puts
    puts "【実行コマンド】"
    puts command
    if exec_flag
      `#{command}`.display
      puts "実行しました。"

      puts
      puts "----【実行後のプロセス確認】----"
      puts
      ps_aux
    else
      puts
      puts "本当に実行するには -x オプションをつけてください。"
    end
  end

  def ps_aux
    lines = `ps aux`.lines.find_all{|line|line.match(/#{@regexp}/)}

    # 自分のプロセスを除去
    lines.reject!{|line|line.match(/^\w+\s+#{Process.pid}\b/)}

    puts "【ps auxの対象行】"
    if lines.empty?
      puts "なし"
      return []
    end

    lines.each{|line|
      puts line
    }

    puts
    puts "【対象のプロセスID】"
    process_ids = lines.map{|line|line.match(/^\S+\s+(\d+)/).captures.first.to_i}.sort.reverse

    # 念のために自分プロセスを除去
    process_ids -= [Process.pid]

    puts process_ids.join(" ")
    process_ids
  end

end

if $0 == __FILE__
  Safekill.new(*ARGV).run
end