class Dog

    attr_accessor :id, :name, :breed

    def initialize(id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end

    def self.create_table
        sql = <<-SQL
        create table if not exists dogs (
            id integer primary key,
            name text,
            breed text);
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        DB[:conn].execute("drop table dogs")
    end

    def save
        sql = "insert into dogs (name, breed) values (?, ?)"
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("select last_insert_rowid() from dogs")[0][0]
        self
    end

    def self.create(name:, breed:)
        Dog.new(name:name, breed:breed).save
    end

    def self.new_from_db(row)
        id, name, breed = row[0], row[1], row[2]
        Dog.new(id: id, name: name, breed: breed)
    end

    def self.find_by_id(id)
        sql = "select * from dogs where id = ? limit 1"    
        DB[:conn].execute(sql, id).collect { |row| self.new_from_db(row)}.first
    end

    def self.find_by_name(name)
        sql = "select * from dogs where name = ? limit 1"    
        DB[:conn].execute(sql, name).collect { |row| self.new_from_db(row)}.first
    end

    def self.find_or_create_by(name:, breed:)
        sql = "select * from dogs where name = ? and breed = ? limit 1"
        dog = DB[:conn].execute(sql, name, breed)
        if !dog.empty?
            Dog.new(id: dog[0][0], name: dog[0][1], breed: dog[0][2])
        else
            self.create(name: name, breed: breed)
        end
    end

    def update
        sql = "update dogs set name = ?, breed = ? where id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
end