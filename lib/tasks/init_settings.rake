desc '针对特定类型项目进行基础配置，调用方法： rake "init_settings[audit_data]"  '

task :init_settings, [:folder] => :environment do |t, args|
  # 涉及到的数据表
  # custom_fields 自定义属性
  # enabled_modules 激活的模块
  # enumerations 枚举值
  # issue_categories 任务分类
  # roles 角色
  # settings 全局设置
  # trackers 跟踪标记
  # workflows 工作流
  Dir::foreach(Rails.root.join("lib", "tasks", args[:folder])) do |f|
    if f != '.' && f != '..'
      puts "更新数据表：" + f + "……"
      import_one_table f.split('.')[0], Rails.root.join("lib", "tasks", args[:folder], f)
    end
  end
end

# 导入一个文件中的数据到一张数据表
# t：数据表名
# f：文件名（全路径）
def import_one_table(t, f)
  cnn = ActiveRecord::Base.connection
  cnn.execute "DELETE FROM #{t};"
  File.readlines(f).each do |r|
    sql = "INSERT INTO #{t} VALUES (#{r.split("\t").map{ |c| c.gsub(/\n/, '').gsub("'", "''") }.map{ |c| c == "\\N" ? 'NULL' : "E'" + c + "'"}.join(', ')});"
    # puts r
    # puts r.split("\t").to_s
    # puts r.split("\t").map{ |c| c.gsub(/\n/, '') }.to_s
    # puts sql
    begin
      cnn.execute(sql)
    rescue
      puts "ERROR: "
      puts r.split("\t").map{ |c| c.gsub(/\n/, '') }.to_s
      puts sql
    end
  end
  # 更新主键序列
  cnn.execute "ALTER SEQUENCE #{f}_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 1000000 START 101 CACHE 101;"
end