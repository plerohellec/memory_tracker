module MemoryTracker
  class Logger
    include Sys
    include Singleton
    attr_reader :memory_logfile, :memory_log, :last_rss, :last_gcstats

    def initialize
      @memory_logfile = File.open(Rails.root.join("log", MEMORY_LOG), 'a')
      @memory_log = ActiveSupport::BufferedLogger.new(memory_logfile)
      @memory_log.level = ActiveSupport::BufferedLogger::INFO

      @last_rss = 0.0
      @last_gcstats = {}
    end

    def log(request)
      pid = Process.pid
      rss = ProcTable.ps(pid).rss * 0.004096
      vsize = ProcTable.ps(pid).vsize * 0.000001
      gcstats = GC.stat

      log_msg = "#{Time.now.localtime.strftime("%m-%d %H:%M:%S")} pid:#{'%05d' % pid} #{request.status}"
      log_msg << " rss=#{'%6.2f' % rss}"
      log_msg << " vsize=#{'%6.2f' % vsize}"

      if (rss / @last_rss > 1.005) || gcstats[:heap_used] - @last_gcstats[:heap_used] > 0
        log_msg << " *** #{GcStat.gcdiff(@last_gcstats, gcstats).inspect}"
      end

      log_msg << " #{request.path}"

      @memory_log.info log_msg
      @memory_logfile.flush
      @last_rss = rss
      @last_gcstats = gcstats
    end
  end
end
