#Dir.[]:ワイルドカードの展開を行い、 パターンにマッチするファイル名を文字列の配列として返します。 パターンにマッチするファイルがない場合は空の配列を返します。
#ブロックが与えられたときはワイルドカードにマッチしたファイルを 引数にそのブロックを 1 つずつ評価して nil を返します

Dir.glob(File.join(Rails.root, 'db', 'seeds', '*.rb')).each do |file|
  desc "Load the seed data from db/seeds/#{File.basename(file)}."
  task "db:seed:#{File.basename(file).gsub(/\..+$/, '')}" => :environment do
    load(file)
  end
end
