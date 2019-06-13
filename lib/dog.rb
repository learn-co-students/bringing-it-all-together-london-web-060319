require "pry"

class Dog

    attr_reader(:name, :breed, :id)
    attr_writer(:name)

    def initialize(name:, breed:, id: nil)
        @name = name
        @breed = breed
        @id = id
    end

    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
        );
        SQL

        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = "DROP TABLE dogs"

        DB[:conn].execute(sql)
    end

    def save
            sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
            DB[:conn].execute(sql, self.name, self.breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
            self
    end

    def self.create(name:, breed:)
        dog = Dog.new(name: name, breed: breed)
        dog.save
    end

    def self.all
        sql = "SELECT * FROM dogs"
        DB[:conn].execute(sql)
    end

    def self.hydrate(arr)
        Dog.new(name: arr[1], breed: arr[2], id: arr[0])
    end

    def self.find_by_id(id)
        sql = "SELECT * FROM dogs WHERE id = ?"
        DB[:conn].execute(sql, id).map {|dog| self.hydrate(dog)}.first
    end

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
            SELECT * 
            FROM dogs
            WHERE name = ?
            AND breed = ?
        SQL
        dog = DB[:conn].execute(sql, name, breed)
        if dog.empty?
            self.create(name: name, breed: breed)
        else
            self.hydrate(dog.first)
        end 
    end

    def self.new_from_db(row)
        self.hydrate(row)
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE name = ?
        SQL
        self.hydrate(DB[:conn].execute(sql, name).first)
    end

    def update
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE id = ?
        SQL
        check = DB[:conn].execute(sql, self.id)

        if !check.empty?
            sql1 = <<-SQL
                UPDATE dogs
                SET name = ?, breed = ?
                WHERE id = ?
            SQL
            DB[:conn].execute(sql1, self.name, self.breed, self.id)
        end
            
    end

end