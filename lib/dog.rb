class Dog
  attr_accessor :name, :breed, :id
  @@all = []
  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
    @@all << self
  end

  def self.create_table
    sql = <<-sql
      CREATE TABLE dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      );
    sql
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-sql
      DROP TABLE IF EXISTS dogs;
    sql
    DB[:conn].execute(sql)
  end

  def save
    sql = <<-sql
      INSERT INTO dogs(name, breed)
      VALUES (?, ?);
      sql
    DB[:conn].execute(sql, self.name, self.breed)
    sql2 = <<-sql
        SELECT last_insert_rowid()
        FROM dogs

      sql
    self.id = DB[:conn].execute(sql2)[0][0]

    self
  end

  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
  end

  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.all
    sql = <<-sql
    SELECT *
    FROM dogs
    sql

    DB[:conn].execute(sql).map do |row|
      self.new_from_db(row)
    end
  end

  def self.find_by_name(name)
    sql = <<-sql 
    SELECT *
    FROM dogs
    WHERE name = ?
    sql

    record = DB[:conn].execute(sql, name)
    self.new_from_db(record[0])
  end

  def self.find(id)
    sql = <<-sql 
    SELECT *
    FROM dogs
    WHERE id = ?
    sql

    record = DB[:conn].execute(sql, id)
    self.new_from_db(record[0])
  end

  # def update
  #   sql = <<-SQL
  #     UPDATE dogs
  #     SET
  #       name = ?,
  #       breed = ?
  #     WHERE id = ?;
  #   SQL
  #   DB[:conn].execute(sql, self.name, self.breed, self.id)
  # end
end
