namespace EBook_Data.Common
{
    public class DynamicEqualityComparer<T> : IEqualityComparer<T>
    {
        private readonly Func<T, object>[] keySelectors;

        public DynamicEqualityComparer(params Func<T, object>[] keySelectors)
        {
            this.keySelectors = keySelectors ?? throw new ArgumentNullException(nameof(keySelectors));
        }

        public bool Equals(T x, T y)
        {
            if (x == null || y == null)
                return x == null && y == null;

            return keySelectors.All(selector => Equals(selector(x), selector(y)));
        }

        public int GetHashCode(T obj)
        {
            if (obj == null)
                throw new ArgumentNullException(nameof(obj));

            unchecked
            {
                int hash = 17;

                foreach (var selector in keySelectors)
                {
                    hash = hash * 31 + (selector(obj)?.GetHashCode() ?? 0);
                }

                return hash;
            }
        }
    }
}
