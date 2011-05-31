require 'starling'

class IDLER

  def init
    starling = Starling.new('localhost:22122')

    Account.all.each do |account|
      if account.active
        starling.set('idler_queue', "start #{account.id} #{account.username} #{account.password}")
      else
        starling.set('idler_queue', "stop #{account.id}")
      end
    end
  end
end