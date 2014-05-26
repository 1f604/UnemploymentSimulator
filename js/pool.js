define(["jquery"], function($) {
    function Pool(factory, pool) {
        this.factory = factory;
        this.objects = {};
        if (pool && pool.objects) {
            for (var key in pool.objects) {
                this.objects[key] = factory.copy(pool.objects[key]);
            }
        }
    }

    Pool.prototype.toJSON = function() {
        return this.objects;
    };

    Pool.prototype.get = function(id) {
        return this.objects[id];
    };

    Pool.prototype.put = function(obj) {
        if (!obj instanceof Object) {
            throw Error(obj + " is not an object!");
        }
        this.objects[obj.id] = obj;
    };

    Pool.prototype.all = function() {
        return this.objects;
    };

    Pool.prototype.each = function(callback) {
        $.each(this.all(), callback);
    };

    Pool.prototype.clear = function() {
        this.objects = {};
    };

    Object.defineProperty(Pool.prototype, "length", {
        get: function() {
            return Object.keys(this.objects).length;
        },
    });

    return Pool;
});
