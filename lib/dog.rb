class Dog
    attr_accessor :name
    attr_reader :id, :breed
    def initialize(id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end

    def self.create_table
        sql = "CREATE TABLE dogs(id INTEGER PRIMARY KEY, name TEXT, breed TEXT)"
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = "DROP TABLE dogs"
        DB[:conn].execute(sql)
    end

    def save
        if @id
            sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
            DB[:conn].execute(sql, self.name, self.breed, self.id)
        else
            sql = "INSERT INTO dogs(name, breed) VALUES (?, ?)"
            DB[:conn].execute(sql, self.name, self.breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
        self
    end

    def self.create(name:, breed:)
        dog = Dog.new(name: name, breed: breed)
        dog.save
    end

    def self.new_from_db(row)
        self.new(id: row[0], name: row[1], breed: row[2])
    end
    
    def self.find_by_id(id)
        sql = "SELECT * FROM dogs WHERE id = ?"
        DB[:conn].execute(sql, id).map{|row| self.new_from_db(row)}.first
    end

    def self.find_by_name(name)
        sql = "SELECT * FROM dogs WHERE name = ?"
        DB[:conn].execute(sql, name).map{|row| self.new_from_db(row)}.first
    end

    def update
        self.save
    end

    def self.find_or_create_by(name:, breed:)
        sql = "SELECT * FROM dogs WHERE name = ? AND breed = ? LIMIT 1"
        dog = DB[:conn].execute(sql, name, breed)

        if !dog.empty?
            data = dog[0]
            new_dog = Dog.new(id: data[0], name: data[1], breed: data[2])
        else
            new_dog = self.create(name: name, breed: breed)
        end
        new_dog
    end
end